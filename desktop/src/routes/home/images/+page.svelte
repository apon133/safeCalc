<script>
  import { goto } from '$app/navigation';
  import * as idb from 'idb-keyval';
  import { onMount } from 'svelte';
  
  let images = $state([]);
  let fileInput;

  onMount(async () => {
    const stored = await idb.get('safeCalc_images');
    if (stored) {
      images = stored;
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
        const newImages = [...images, evt.target.result];
        images = newImages;
        await idb.set('safeCalc_images', newImages);
      };
      reader.readAsDataURL(file);
    }
  }

  async function deleteImage(index) {
    if (confirm('Are you sure you want to delete this image?')) {
      const newImages = images.filter((_, i) => i !== index);
      images = newImages;
      await idb.set('safeCalc_images', newImages);
    }
  }

  async function unlockImage(img, index) {
    // specific "Unlock" behavior: Save to disk, then remove from vault
    const a = document.createElement('a');
    a.href = img;
    a.download = `safeCalc_img_${Date.now()}.png`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);

    // Remove from vault automatically after unlocking (moving out)
    const newImages = images.filter((_, i) => i !== index);
    images = newImages;
    await idb.set('safeCalc_images', newImages);
  }
</script>

<div class="page">
  <header>
    <button class="back-btn" onclick={() => goto('/home')} aria-label="Go Back">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"/><path d="M12 19l-7-7 7-7"/></svg>
    </button>
    <h1>Images</h1>
  </header>

  <div class="content">
    {#if images.length === 0}
      <div class="empty-state">
        <p>No images hidden yet</p>
      </div>
    {:else}
      <div class="grid">
        {#each images as img, i}
          <div class="image-item">
            <img src={img} alt="Hidden {i}" />
            <div class="overlay">
              <button class="action-btn unlock-btn" onclick={() => unlockImage(img, i)} aria-label="Unlock (Save & Remove)">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              </button>
              <button class="action-btn delete-btn" onclick={() => deleteImage(i)} aria-label="Delete">
                 <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
              </button>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <button class="fab" onclick={handleAdd} aria-label="Add Image">
    <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
  </button>
  <input type="file" accept="image/*" bind:this={fileInput} onchange={onFileSelected} hidden />
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
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); /* slightly larger for buttons */
    gap: 12px;
  }

  .image-item {
    aspect-ratio: 1;
    border-radius: 8px;
    overflow: hidden;
    background: #1a1a1a;
    position: relative;
    group: hover;
  }

  .image-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.3s;
  }

  .overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
    padding: 10px;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    opacity: 0;
    transition: opacity 0.2s;
  }
  
  /* Show overlay on hover or active (mobile tap) */
  .image-item:hover .overlay, .image-item:active .overlay {
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
    background-color: #63FFDA;
    color: #000;
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
