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

  let selectedIndex = $state(-1);

  function openLightbox(index) {
    selectedIndex = index;
  }

  function closeLightbox() {
    selectedIndex = -1;
  }

  function nextVideo(e) {
    e?.stopPropagation();
    if (videos.length > 0) {
      selectedIndex = (selectedIndex + 1) % videos.length;
    }
  }

  function prevVideo(e) {
    e?.stopPropagation();
    if (videos.length > 0) {
      selectedIndex = (selectedIndex - 1 + videos.length) % videos.length;
    }
  }

  function handleKeydown(e) {
    if (selectedIndex !== -1) {
      if (e.key === 'Escape') closeLightbox();
      if (e.key === 'ArrowRight') nextVideo();
      if (e.key === 'ArrowLeft') prevVideo();
    }
  }

  async function deleteVideo(index, e) {
    e?.stopPropagation();
    if (confirm('Are you sure you want to delete this video?')) {
      const newVideos = videos.filter((_, i) => i !== index);
      videos = newVideos;
      await idb.set('safeCalc_videos', newVideos);
      if (selectedIndex === index) closeLightbox();
    }
  }

  async function unlockVideo(vid, index, e) {
    e?.stopPropagation();
    const a = document.createElement('a');
    a.href = vid;
    a.download = `safeCalc_video_${Date.now()}.mp4`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    const newVideos = videos.filter((_, i) => i !== index);
    videos = newVideos;
    await idb.set('safeCalc_videos', newVideos);
    if (selectedIndex === index) closeLightbox();
  }
</script>

<svelte:window onkeydown={handleKeydown} />

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
          <!-- svelte-ignore a11y_click_events_have_key_events -->
          <div class="video-item" onclick={() => openLightbox(i)} role="button" tabindex="0">
            <video src={vid} preload="metadata">
              <track kind="captions" />
            </video>
            <div class="overlay">
              <button class="action-btn unlock-btn" onclick={(e) => unlockVideo(vid, i, e)} aria-label="Unlock (Save & Remove)">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              </button>
              <button class="action-btn delete-btn" onclick={(e) => deleteVideo(i, e)} aria-label="Delete">
                 <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
              </button>
            </div>
            <!-- Play icon overlay -->
            <div class="play-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="white" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="5 3 19 12 5 21 5 3"/></svg>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  {#if selectedIndex > -1}
    <!-- svelte-ignore a11y_click_events_have_key_events -->
    <div class="lightbox" onclick={closeLightbox} role="button" tabindex="0">
      <button class="nav-btn prev" onclick={prevVideo}>
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
      </button>
      
      <div class="lightbox-content" onclick={(e) => e.stopPropagation()} role="presentation">
        <!-- Keyed block to force re-render when index changes, ensuring autoplay works -->
        {#key selectedIndex}
          <video src={videos[selectedIndex]} controls autoplay class="fullscreen-video">
            <track kind="captions" />
          </video>
        {/key}
      </div>

      <button class="nav-btn next" onclick={nextVideo}>
        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
      </button>

      <button class="close-btn" onclick={closeLightbox}>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      </button>
    </div>
  {/if}

  <button class="fab" onclick={handleAdd} aria-label="Add Video">
    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
  </button>
  <input type="file" accept="video/*" bind:this={fileInput} onchange={onFileSelected} hidden />
</div>

<style>
  /* ... existing styles ... */
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
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 12px;
  }

  .video-item {
    aspect-ratio: 16/9;
    border-radius: 8px;
    overflow: hidden;
    background: #1a1a1a;
    position: relative;
    group: hover;
    cursor: pointer;
  }

  .video-item video {
    width: 100%;
    height: 100%;
    object-fit: contain;
    background: black;
    pointer-events: none; /* Let clicks pass to container */
  }
  
  .play-icon {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    opacity: 0.7;
    pointer-events: none;
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
  }
  
  .video-item:hover .overlay {
    opacity: 1;
  }
  
  .overlay button {
    pointer-events: auto;
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

  /* Lightbox Styles */
  .lightbox {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.95);
    z-index: 1000;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .lightbox-content {
    width: 90%;
    max-width: 1000px;
    aspect-ratio: 16/9;
  }

  .fullscreen-video {
    width: 100%;
    height: 100%;
    background: black;
    box-shadow: 0 0 20px rgba(0,0,0,0.5);
  }

  .nav-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255, 255, 255, 0.1);
    color: white;
    border: none;
    border-radius: 50%;
    width: 48px;
    height: 48px;
    display: flex;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    transition: background 0.2s;
  }

  .nav-btn:hover {
    background: rgba(255, 255, 255, 0.2);
  }

  .prev { left: 20px; }
  .next { right: 20px; }

  .close-btn {
    position: absolute;
    top: 20px;
    right: 20px;
    background: transparent;
    color: white;
    border: none;
    width: 40px;
    height: 40px;
    cursor: pointer;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 50%;
  }
  
  .close-btn:hover {
    background: rgba(255, 255, 255, 0.1);
  }
</style>
