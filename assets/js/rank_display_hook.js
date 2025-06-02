export const RankDisplayHook = {
  mounted() {
    this.updateBadge();

    // Listen for localStorage changes from other tabs
    window.addEventListener("storage", (e) => {
      if (e.key === "josaa_user_rank") this.updateBadge();
    });

    // Listen for rank changes from same tab
    window.addEventListener("user-rank-changed", () => {
      this.updateBadge();
    });
  },

  updateBadge() {
    const userRank = parseInt(localStorage.getItem("josaa_user_rank"));
    const rank = parseInt(this.el.dataset.rank);

    // Reset to base classes
    // this.el.className = "font-bold";

    if (!userRank || isNaN(userRank)) {
      // State 1: No user rank - Gray
      this.el.classList.add("text-blue-600", "dark:text-blue-400");
      return;
    }

    if (userRank <= rank) {
      // State 2: User can achieve this rank - Green
      this.el.classList.add("text-green-600", "dark:text-green-400");
    } else {
      // Calculate simple buffer (10% of rank, min 50, max 1000)
      const buffer = Math.min(Math.max(Math.round(rank * 0.1), 50), 1000);

      if (userRank <= rank + buffer) {
        // State 3: Stretch goal - Orange
        this.el.classList.add("text-orange-600", "dark:text-orange-400");
      } else {
        // State 4: Very difficult - Red
        this.el.classList.add("text-red-600", "dark:text-red-400");
      }
    }
  },

  destroyed() {
    // Cleanup if needed
  },
};
