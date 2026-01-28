<script>
  import { goto } from '$app/navigation';

  function navigate(path) {
    goto(path);
  }
</script>

<div class="home-page">
  <header>
    <h1>Safe Vault</h1>
  </header>

  <div class="content">
    <div class="subtitle">Your Protected Media</div>

    <div class="grid">
      <!-- Images Box -->
      <button class="grid-box images" onclick={() => navigate('/home/images')}>
        <div class="icon-circle">
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
        </div>
        <div class="box-name">Images</div>
      </button>

      <!-- Cloud Box -->
      <button class="grid-box cloud" onclick={() => navigate('/home/cloud')}>
        <div class="icon-circle">
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>
        </div>
        <div class="box-name">Cloud</div>
      </button>

      <!-- Videos Box -->
      <button class="grid-box videos" onclick={() => navigate('/home/videos')}>
        <div class="icon-circle">
          <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/></svg>
        </div>
        <div class="box-name">Videos</div>
      </button>
    </div>

    <div class="footer">
      apon133
    </div>
  </div>
</div>

<style>
  .home-page {
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: #0F0F0F;
    font-family: 'Inter', sans-serif;
  }

  header {
    padding: 16px;
    text-align: center;
  }

  header h1 {
    font-size: 20px;
    font-weight: bold;
    letter-spacing: 1.5px;
    color: #fff;
    margin: 0;
  }

  .content {
    flex: 1;
    padding: 0 20px;
    display: flex;
    flex-direction: column;
  }

  .subtitle {
    color: rgba(255, 255, 255, 0.6);
    font-size: 14px;
    font-weight: 300;
    letter-spacing: 1.1px;
    margin: 20px 0;
  }

  .grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    flex: 1;
  }

  .grid-box {
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.1);
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    cursor: pointer;
    transition: transform 0.2s;
    background: transparent;
    padding: 0;
  }

  .grid-box:hover {
    transform: scale(1.02);
  }

  .icon-circle {
    padding: 16px;
    background: rgba(255,255,255,0.1);
    border-radius: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-bottom: 16px;
  }

  .box-name {
    font-size: 18px;
    font-weight: 500;
    color: #fff;
  }

  /* Specific Styles */
  /* Images: 0xFF63FFDA, 0xFF00BFA5 */
  .images {
    background: linear-gradient(to bottom right, rgba(99, 255, 218, 0.15), rgba(0, 191, 165, 0.05));
    border-color: rgba(99, 255, 218, 0.2);
  }
  .images .icon-circle {
    background-color: rgba(99, 255, 218, 0.1);
    color: #63FFDA;
  }

  /* Cloud: 0xFF42A5F5, 0xFF1976D2 */
  .cloud {
    background: linear-gradient(to bottom right, rgba(66, 165, 245, 0.15), rgba(25, 118, 210, 0.05));
    border-color: rgba(66, 165, 245, 0.2);
  }
  .cloud .icon-circle {
    background-color: rgba(66, 165, 245, 0.1);
    color: #42A5F5;
  }

  /* Videos: 0xFFFF7043, 0xFFE64A19 */
  .videos {
    background: linear-gradient(to bottom right, rgba(255, 112, 67, 0.15), rgba(230, 74, 25, 0.05));
    border-color: rgba(255, 112, 67, 0.2);
  }
  .videos .icon-circle {
    background-color: rgba(255, 112, 67, 0.1);
    color: #FF7043;
  }

  .footer {
    text-align: center;
    padding-bottom: 24px;
    color: rgba(255, 255, 255, 0.2);
    font-size: 12px;
    letter-spacing: 2px;
  }
</style>
