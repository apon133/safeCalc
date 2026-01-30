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

  async function deleteVideo(index) {
    if (confirm('Are you sure you want to delete this video?')) {
      const newVideos = videos.filter((_, i) => i !== index);
      videos = newVideos;
      await idb.set('safeCalc_videos', newVideos);
    }
  }

  async function unlockVideo(vid, index) {
    const a = document.createElement('a');
    a.href = vid;
    a.download = `safeCalc_video_${Date.now()}.mp4`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    const newVideos = videos.filter((_, i) => i !== index);
    videos = newVideos;
    await idb.set('safeCalc_videos', newVideos);
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
            <div class="overlay">
              <button class="action-btn unlock-btn" onclick={() => unlockVideo(vid, i)} aria-label="Unlock (Save & Remove)">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              </button>
              <button class="action-btn delete-btn" onclick={() => deleteVideo(i)} aria-label="Delete">
                 <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
              </button>
            </div>
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
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); /* Larger for videos */
    gap: 12px;
  }

  .video-item {
    aspect-ratio: 16/9;
    border-radius: 8px;
    overflow: hidden;
    background: #1a1a1a;
    position: relative;
    group: hover;
  }

  .video-item video {
    width: 100%;
    height: 100%;
    object-fit: contain;
    background: black;
  }

  .overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    background: linear-gradient(to bottom, rgba(0,0,0,0.8), transparent);
    padding: 10px;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    opacity: 0;
    transition: opacity 0.2s;
    pointer-events: none; /* Let clicks pass through generally */
  }

  /* But re-enable pointer events on buttons */
  .overlay button {
    pointer-events: auto;
  }
  
  /* Show overlay on hover */
  .video-item:hover .overlay {
    opacity: 1;
  }

  .action-btn {
    background: rgba(255, 255, 255, 0.2);
    border: none;
    border-radius: 4px;
    width: 32px;
    height: 32px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    color: white;
    backdrop-filter: blur(4px);
  }

  .delete-btn:hover {
    background: rgba(255, 82, 82, 0.8);
  }
  
  .unlock-btn:hover {
    background: rgba(99, 255, 218, 0.8);
    color: black;
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
