export const RankBadgeHook = {
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
    this.el.className =
      "rank-badge px-2 py-1 text-sm font-medium rounded-md transition-colors duration-200";

    if (!userRank || isNaN(userRank)) {
      // State 1: No user rank - Gray
      // this.el.classList.add('bg-gray-100', 'text-gray-800', 'dark:bg-gray-700', 'dark:text-gray-200');
      return;
    }

    if (userRank <= rank) {
      // State 2: User can achieve this rank - Green
      this.el.classList.add(
        "bg-green-100",
        "text-green-800",
        "dark:bg-green-900",
        "dark:text-green-200",
      );
    } else {
      // Calculate simple buffer (10% of rank, min 50, max 1000)
      const buffer = Math.min(Math.max(Math.round(rank * 0.1), 50), 1000);

      if (userRank <= rank + buffer) {
        // State 3: Stretch goal - Orange
        this.el.classList.add(
          "bg-orange-100",
          "text-orange-800",
          "dark:bg-orange-900",
          "dark:text-orange-200",
        );
      } else {
        // State 4: Very difficult - Red
        this.el.classList.add(
          "bg-red-100",
          "text-red-800",
          "dark:bg-red-900",
          "dark:text-red-200",
        );
      }
    }
  },

  destroyed() {
    // Cleanup if needed
  },
};
