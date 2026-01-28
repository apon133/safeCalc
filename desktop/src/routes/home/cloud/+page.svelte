<script>
  import { goto } from '$app/navigation';
  import * as idb from 'idb-keyval';
  import { onMount } from 'svelte';
  
  let itemUrl = $state("");
  let cloudItems = $state([]);

  onMount(async () => {
    const stored = await idb.get('safeCalc_cloudItems');
    if (stored) {
      cloudItems = stored;
    }
  });

  async function addItem() {
    if (itemUrl) {
      const newItems = [...cloudItems, { url: itemUrl, date: new Date().toLocaleDateString() }];
      cloudItems = newItems;
      await idb.set('safeCalc_cloudItems', newItems);
      itemUrl = "";
    }
  }
</script>

<div class="page">
  <header>
    <button class="back-btn" onclick={() => goto('/home')} aria-label="Go Back">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"/><path d="M12 19l-7-7 7-7"/></svg>
    </button>
    <h1>Cloud</h1>
  </header>

  <div class="content">
    <div class="input-area">
      <input type="text" placeholder="Enter Image URL" bind:value={itemUrl} />
      <button onclick={addItem}>Add</button>
    </div>

    {#if cloudItems.length === 0}
      <div class="empty-state">
        <p>No cloud items added</p>
      </div>
    {:else}
      <div class="list">
        {#each cloudItems as item, i}
          <div class="cloud-item">
             <div class="preview">
               <img src={item.url} alt="Cloud Item" onerror={(e) => e.target.src = 'https://via.placeholder.com/150?text=Error'}/>
             </div>
             <div class="info">
               <div class="url">{item.url}</div>
               <div class="date">{item.date}</div>
             </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>

<style>
  .page {
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: #0F0F0F;
    font-family: 'Inter', sans-serif;
    color: white;
  }

  header {
    display: flex;
    align-items: center;
    padding: 16px;
    background: rgba(255, 255, 255, 0.02);
  }

  .back-btn {
    background: transparent;
    border: none;
    color: white;
    cursor: pointer;
    margin-right: 16px;
    padding: 8px;
    border-radius: 50%;
  }

  .back-btn:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  h1 {
    font-size: 20px;
    margin: 0;
    font-weight: 600;
  }

  .content {
    flex: 1;
    padding: 20px;
    display: flex;
    flex-direction: column;
  }

  .input-area {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
  }

  input {
    flex: 1;
    background: #1E1E1E;
    border: 1px solid #333;
    padding: 12px;
    border-radius: 8px;
    color: white;
    outline: none;
  }

  input:focus {
    border-color: #42A5F5;
  }

  .input-area button {
    background: #42A5F5;
    color: white;
    border: none;
    padding: 0 20px;
    border-radius: 8px;
    font-weight: bold;
    cursor: pointer;
  }

  .empty-state {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    color: rgba(255, 255, 255, 0.3);
  }

  .list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .cloud-item {
    background: #1a1a1a;
    padding: 12px;
    border-radius: 12px;
    display: flex;
    gap: 12px;
    align-items: center;
  }

  .preview {
    width: 60px;
    height: 60px;
    border-radius: 8px;
    overflow: hidden;
    background: #000;
  }

  .preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .info {
    flex: 1;
    overflow: hidden;
  }

  .url {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 14px;
    margin-bottom: 4px;
  }

  .date {
    font-size: 12px;
    color: rgba(255, 255, 255, 0.5);
  }
</style>
