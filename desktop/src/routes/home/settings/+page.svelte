<script>
  import * as idb from 'idb-keyval';

  let savedPassword = null;

  async function clearPassword() {
    await idb.del('safeCalc_password');
    await idb.del('safeCalc_images');
    await idb.del('safeCalc_videos');
    await idb.del('safeCalc_cloudItems');
    // Also clear localStorage just in case
    localStorage.removeItem('safeCalc_password'); 
    alert('All data (password and media) cleared. Application will ask to set a new one on next launch.');
  }
</script>

<div class="settings-page">
  <header>
    <h1>Settings</h1>
  </header>
  
  <div class="content">
    <div class="section">
      <h2>Security</h2>
      <button class="setting-item" onclick={clearPassword}>
        <span class="icon">🔒</span>
        <span class="label">Reset Password</span>
      </button>
    </div>

    <div class="section">
      <h2>About</h2>
      <div class="setting-item">
        <span class="icon">ℹ️</span>
        <span class="label">Version 1.0.0</span>
      </div>
    </div>
  </div>
</div>

<style>
  .settings-page {
    height: 100%;
    display: flex;
    flex-direction: column;
    background-color: #0F0F0F;
    font-family: 'Inter', sans-serif;
    color: #fff;
  }

  header {
    padding: 16px;
    text-align: center;
  }

  header h1 {
    font-size: 20px;
    font-weight: bold;
    letter-spacing: 1.5px;
    margin: 0;
  }

  .content {
    flex: 1;
    padding: 20px;
  }

  .section {
    margin-bottom: 24px;
  }

  h2 {
    color: #63FFDA;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    margin-bottom: 12px;
  }

  .setting-item {
    background: rgba(255, 255, 255, 0.05);
    padding: 16px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    width: 100%;
    border: none;
    color: white;
    font-size: 16px;
    cursor: pointer;
    text-align: left;
    margin-bottom: 8px;
  }

  .setting-item:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .icon {
    margin-right: 16px;
    font-size: 20px;
  }
</style>
