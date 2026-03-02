export const RankInputHook = {
  mounted() {
    // Read existing rank from localStorage on mount
    const existingRank = localStorage.getItem('josaa_user_rank');
    if (existingRank) {
      this.el.value = existingRank;
      // Notify the server so rank filter is applied in the query.
      // Without this, the server has no rank and push_patch from other
      // filters (Boolean toggles) would produce a URL without rank.
      this.el.dispatchEvent(new Event('input', { bubbles: true }));
    }

    // Listen for input changes
    this.el.addEventListener('input', (event) => {
      const rank = event.target.value;

      if (rank && !isNaN(parseInt(rank)) && parseInt(rank) > 0) {
        localStorage.setItem('josaa_user_rank', rank);
        window.dispatchEvent(new CustomEvent('user-rank-changed', {
          detail: { rank: parseInt(rank) }
        }));
      } else {
        localStorage.removeItem('josaa_user_rank');
        window.dispatchEvent(new CustomEvent('user-rank-changed', {
          detail: { rank: null }
        }));
      }
    });

    // Listen for localStorage changes from other tabs
    this._onStorage = (event) => {
      if (event.key === 'josaa_user_rank') {
        const newRank = event.newValue;
        if (newRank !== this.el.value) {
          this.el.value = newRank || '';
          this.el.dispatchEvent(new Event('input', { bubbles: true }));
        }
      }
    };
    window.addEventListener('storage', this._onStorage);
  },

  destroyed() {
    window.removeEventListener('storage', this._onStorage);
  }
};