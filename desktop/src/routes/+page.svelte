<script>
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import * as idb from 'idb-keyval';

  let input = $state("");
  let result = $state("");
  let savedPassword = $state(null);
  let showPasswordDialog = $state(false);
  let dialogMode = $state('set'); // 'set', 'check_old', 'change'
  let dialogInput = $state("");
  let oldPasswordInput = $state("");

  onMount(async () => {
    try {
      const stored = await idb.get('safeCalc_password');
      if (stored) {
        savedPassword = stored;
      }
    } catch (e) {
      console.error("Failed to load password", e);
    }
  });

  function addNumber(val) {
    if (val === 'C') {
      input = "";
      result = "";
    } else if (val === 'Del') {
      if (input.length > 0) {
        input = input.slice(0, -1);
      }
    } else {
      input += val;
    }
  }

  function evaluate() {
    try {
      // Replace symbols for JS evaluation
      let expression = input.replace(/×/g, '*').replace(/÷/g, '/');
      // Simple and somewhat safe evaluation for allowed characters
      if (/^[0-9+\-*/().% ]+$/.test(expression)) {
         // eslint-disable-next-line no-new-func
         result = new Function('return ' + expression)().toString();
      }
    } catch (e) {
      result = "Error";
    }
  }

  function handleEqual() {
    if (savedPassword === null) {
      openDialog('set');
    } else {
      evaluate();
      if (input === savedPassword) {
        // Unlock
        input = "";
        result = "";
        goto('/home');
      }
    }
  }

  function handleLongPressEqual() {
    if (savedPassword) {
      openDialog('check_old');
    } else {
      openDialog('set');
    }
  }

  // Long press handling
  let pressTimer;
  function startLongPress() {
    pressTimer = setTimeout(() => {
        handleLongPressEqual();
    }, 800);
  }
  function cancelLongPress() {
    clearTimeout(pressTimer);
  }

  // Dialog Logic
  function openDialog(mode) {
    dialogMode = mode;
    dialogInput = "";
    oldPasswordInput = "";
    showPasswordDialog = true;
  }

  function closeDialog() {
    showPasswordDialog = false;
  }

  async function submitDialog() {
     if (dialogMode === 'set') {
       if (dialogInput.length > 0) {
         savedPassword = dialogInput;
         await idb.set('safeCalc_password', savedPassword);
         closeDialog();
       }
     } else if (dialogMode === 'check_old') {
       if (dialogInput === savedPassword) {
         openDialog('change'); // Now ask for new password
       } else {
         alert('Incorrect old password');
       }
     } else if (dialogMode === 'change') {
       if (dialogInput.length > 0) {
         savedPassword = dialogInput;
         await idb.set('safeCalc_password', savedPassword);
         closeDialog();
       }
     }
  }
</script>

<main>
  <!-- Display Section -->
  <div class="display-container">
    <div class="input-display">{input}</div>
    {#if result}
      <div class="result-display">{result}</div>
    {/if}
  </div>

  <div class="divider"></div>

  <!-- Keypad Section -->
  <div class="keypad">
    <div class="row">
      <button class="btn fn-btn" onclick={() => addNumber('C')}>C</button>
      <button class="btn fn-btn" onclick={() => addNumber('()')}>()</button>
      <button class="btn fn-btn" onclick={() => addNumber('%')}>%</button>
      <button class="btn fn-btn" onclick={() => addNumber('÷')}>÷</button>
    </div>
    <div class="row">
      <button class="btn" onclick={() => addNumber('7')}>7</button>
      <button class="btn" onclick={() => addNumber('8')}>8</button>
      <button class="btn" onclick={() => addNumber('9')}>9</button>
      <button class="btn fn-btn" onclick={() => addNumber('×')}>×</button>
    </div>
    <div class="row">
      <button class="btn" onclick={() => addNumber('4')}>4</button>
      <button class="btn" onclick={() => addNumber('5')}>5</button>
      <button class="btn" onclick={() => addNumber('6')}>6</button>
      <button class="btn fn-btn" onclick={() => addNumber('-')}>-</button>
    </div>
    <div class="row">
      <button class="btn" onclick={() => addNumber('1')}>1</button>
      <button class="btn" onclick={() => addNumber('2')}>2</button>
      <button class="btn" onclick={() => addNumber('3')}>3</button>
      <button class="btn fn-btn" onclick={() => addNumber('+')}>+</button>
    </div>
    <div class="row">
      <button class="btn" onclick={() => addNumber('0')}>0</button>
      <button class="btn" onclick={() => addNumber('.')}>.</button>
      <button class="btn del-btn" onclick={() => addNumber('Del')}>Del</button>
      <button 
        class="btn equal-btn" 
        onmousedown={startLongPress} 
        onmouseup={cancelLongPress} 
        onmouseleave={cancelLongPress}
        onclick={handleEqual}
      >=</button>
    </div>
  </div>

  <!-- Password Dialog -->
  {#if showPasswordDialog}
    <div class="dialog-overlay">
      <div class="dialog">
        <h3>
          {#if dialogMode === 'set'}Set New Password
          {:else if dialogMode === 'check_old'}Enter Old Password
          {:else}Enter New Password{/if}
        </h3>
        <input type="password" inputmode="numeric" bind:value={dialogInput} placeholder="Password" />
        <div class="dialog-actions">
          <button onclick={closeDialog}>Cancel</button>
          <button onclick={submitDialog}>Submit</button>
        </div>
      </div>
    </div>
  {/if}

</main>

<style>
  :global(:root) {
    --bg-color: #000000;
    --text-color: #ffffff;
    --accent-color: #63FFDA;
    --secondary-accent: #00C853;
  }

  main {
    display: flex;
    flex-direction: column;
    height: 100vh;
    background-color: var(--bg-color);
    color: var(--text-color);
    font-family: 'Inter', sans-serif;
    overflow: hidden;
  }

  .display-container {
    height: 40vh;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    align-items: flex-end;
    padding: 20px;
    box-sizing: border-box;
  }

  .input-display {
    font-size: 45px;
    font-weight: bold;
    word-break: break-all;
    text-align: right;
  }

  .result-display {
    font-size: 32px;
    color: rgba(255, 255, 255, 0.7);
    font-weight: 300;
    margin-top: 10px;
  }

  .divider {
    height: 1px;
    background-color: rgba(255, 255, 255, 0.1);
    margin: 0 20px 10px 20px;
  }

  .keypad {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-evenly;
    padding-bottom: 20px;
  }

  .row {
    display: flex;
    justify-content: space-evenly;
    align-items: center;
  }

  .btn {
    width: 70px;
    height: 70px;
    border-radius: 50%;
    background-color: #1E1E1E; /* Dark Gray for numbers */
    color: #fff;
    font-size: 24px;
    border: none;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
    transition: background-color 0.2s;
  }

  .btn:active {
    background-color: #333;
  }

  .fn-btn {
    color: var(--accent-color);
    background-color: #1E1E1E;
  }

  .del-btn {
    background-color: rgba(255, 82, 82, 0.8);
  }

  .equal-btn {
    background-color: var(--secondary-accent);
  }

  /* Dialog Styles */
  .dialog-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 100;
  }

  .dialog {
    background: #1E1E1E;
    padding: 20px;
    border-radius: 12px;
    min-width: 300px;
    display: flex;
    flex-direction: column;
    gap: 15px;
  }

  .dialog h3 {
    margin: 0;
    color: var(--text-color);
  }

  .dialog input {
    padding: 10px;
    border-radius: 8px;
    border: 1px solid #333;
    background: #000;
    color: #fff;
    font-size: 16px;
  }

  .dialog-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
  }

  .dialog-actions button {
    padding: 8px 16px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    font-weight: bold;
  }

  .dialog-actions button:first-child {
    background: transparent;
    color: #aaa;
  }

  .dialog-actions button:last-child {
    background: var(--accent-color);
    color: #000;
  }
</style>
