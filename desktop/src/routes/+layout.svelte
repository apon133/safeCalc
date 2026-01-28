<script>
  // Global styles are handled in the <style> block
  let { children } = $props();
</script>

{@render children()}

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    overflow: hidden; /* Prevent scrolling on the body if possible, or handle via component */
    background-color: #000;
    font-family: 'Inter', sans-serif;
    user-select: none; /* Mobile-like feel */
  }

  /* Hide scrollbar for Chrome, Safari and Opera */
  :global(::-webkit-scrollbar) {
    display: none;
  }

  /* Hide scrollbar for IE, Edge and Firefox */
  :global(html) {
    -ms-overflow-style: none;  /* IE and Edge */
    scrollbar-width: none;  /* Firefox */
  }
</style>
