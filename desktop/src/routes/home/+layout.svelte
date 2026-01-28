<script>
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';

  let { children } = $props();
  let currentPath = $state("");

  $effect(() => {
     currentPath = $page.url.pathname;
  });

  function navigate(path) {
    goto(path);
  }
</script>

<div class="app-container">
  <div class="content-area">
    {@render children()}
  </div>

  <div class="bottom-nav">
    <button 
      class="nav-item {currentPath === '/home' ? 'active' : ''}" 
      onclick={() => navigate('/home')}
    >
      <div class="icon">🏠</div>
      {#if currentPath === '/home'}
        <span class="label">Home</span>
      {/if}
    </button>
    <button 
      class="nav-item {currentPath === '/home/settings' ? 'active' : ''}"
      onclick={() => navigate('/home/settings')}
    >
      <div class="icon">⚙️</div>
      {#if currentPath === '/home/settings'}
        <span class="label">Settings</span>
      {/if}
    </button>
  </div>
</div>

<style>
  .app-container {
    display: flex;
    flex-direction: column;
    height: 100vh;
    background-color: #000;
    color: #fff;
    font-family: 'Inter', sans-serif;
  }

  .content-area {
    flex: 1;
    overflow-y: auto;
  }

  .bottom-nav {
    height: 70px;
    background-color: #0F0F0F;
    display: flex;
    justify-content: space-around;
    align-items: center;
    box-shadow: 0 -5px 20px rgba(0,0,0,0.5);
    padding-bottom: 10px; /* Safe area padding */
  }

  .nav-item {
    background: transparent;
    border: none;
    color: rgba(255, 255, 255, 0.38);
    display: flex;
    align-items: center;
    padding: 10px 20px;
    border-radius: 20px;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .nav-item.active {
    background-color: rgba(99, 255, 218, 0.1); /* 0xFF63FFDA with opacity */
    color: #63FFDA;
  }

  .icon {
    font-size: 26px;
  }

  .label {
    margin-left: 8px;
    font-weight: bold;
    font-size: 14px;
    color: #63FFDA;
  }
</style>
