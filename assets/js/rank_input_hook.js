export const RankInputHook = {
  mounted() {
    // Read existing rank from localStorage on mount
    const existingRank = localStorage.getItem('josaa_user_rank');
    if (existingRank) {
      this.el.value = existingRank;
    }

    // Listen for input changes
    this.el.addEventListener('input', (event) => {
      const rank = event.target.value;
      
      if (rank && !isNaN(parseInt(rank)) && parseInt(rank) > 0) {
        // Save valid rank to localStorage
        localStorage.setItem('josaa_user_rank', rank);
        
        // Broadcast to all rank badges
        window.dispatchEvent(new CustomEvent('user-rank-changed', {
          detail: { rank: parseInt(rank) }
        }));
      } else {
        // Remove invalid/empty rank
        localStorage.removeItem('josaa_user_rank');
        
        // Broadcast rank cleared
        window.dispatchEvent(new CustomEvent('user-rank-changed', {
          detail: { rank: null }
        }));
      }
    });

    // Listen for localStorage changes from other tabs
    window.addEventListener('storage', (event) => {
      if (event.key === 'josaa_user_rank') {
        const newRank = event.newValue;
        if (newRank !== this.el.value) {
          this.el.value = newRank || '';
        }
      }
    });
  },

  destroyed() {
    // Cleanup if needed
  }
};