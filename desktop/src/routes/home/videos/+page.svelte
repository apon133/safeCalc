<script>
  import { goto } from '$app/navigation';
  import * as idb from 'idb-keyval';
  import { onMount } from 'svelte';
  
  let videos = $state([]);
  let fileInput;

  onMount(async () => {
    const stored = await idb.get('safeCalc_videos');
    if (stored) {
      videos = stored;
    }
  });

  function handleAdd() {
    fileInput.click();
  }

  function onFileSelected(e) {
    const file = e.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = async (evt) => {
        const newVideos = [...videos, evt.target.result];
        videos = newVideos;
        await idb.set('safeCalc_videos', newVideos);
      };
      reader.readAsDataURL(file);
    }
  }
</script>

<div class="page">
  <header>
    <button class="back-btn" onclick={() => goto('/home')} aria-label="Go Back">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"/><path d="M12 19l-7-7 7-7"/></svg>
    </button>
    <h1>Videos</h1>
  </header>

  <div class="content">
    {#if videos.length === 0}
      <div class="empty-state">
        <p>No videos hidden yet</p>
      </div>
    {:else}
      <div class="grid">
        {#each videos as vid, i}
          <div class="video-item">
            <video src={vid} controls>
              <track kind="captions" />
            </video>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <button class="fab" onclick={handleAdd} aria-label="Add Video">
    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
  </button>
  <input type="file" accept="video/*" bind:this={fileInput} onchange={onFileSelected} hidden />
</div>

<style>
  .page {
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: #0F0F0F;
    font-family: 'Inter', sans-serif;
    color: white;
    position: relative;
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
    overflow-y: auto;
  }

  .empty-state {
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    color: rgba(255, 255, 255, 0.3);
  }

  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 12px;
  }

  .video-item {
    aspect-ratio: 16/9;
    border-radius: 8px;
    overflow: hidden;
    background: #1a1a1a;
  }

  .video-item video {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .fab {
    position: absolute;
    bottom: 24px;
    right: 24px;
    width: 56px;
    height: 56px;
    border-radius: 50%;
    background-color: #FF7043;
    color: #fff;
    border: none;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    transition: transform 0.2s;
  }

  .fab:hover {
    transform: scale(1.05);
  }
  
  .fab:active {
    transform: scale(0.95);
  }
</style>
