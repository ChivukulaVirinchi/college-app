const CATEGORY_LABELS = {
  open: "OPEN",
  obc_ncl: "OBC-NCL",
  sc: "SC",
  st: "ST",
  ews: "EWS",
  open_pwd: "OPEN (PwD)",
  obc_ncl_pwd: "OBC-NCL (PwD)",
  sc_pwd: "SC (PwD)",
  st_pwd: "ST (PwD)",
  ews_pwd: "EWS (PwD)",
};

// Index page: category <select> synced with localStorage
export const CategorySelectHook = {
  mounted() {
    const saved = localStorage.getItem("josaa_user_category") || "open";
    this.el.value = saved;

    this.el.addEventListener("change", (e) => {
      localStorage.setItem("josaa_user_category", e.target.value);
      window.dispatchEvent(
        new CustomEvent("user-category-changed", {
          detail: { category: e.target.value },
        })
      );
    });

    // Cross-tab sync
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = event.newValue || "open";
        if (val !== this.el.value) {
          this.el.value = val;
        }
      }
    };
    window.addEventListener("storage", this._storageHandler);
  },

  destroyed() {
    window.removeEventListener("storage", this._storageHandler);
  },
};

// Show page: auto-apply saved category as default Select filter
export const CategoryFilterHook = {
  mounted() {
    const category = localStorage.getItem("josaa_user_category") || "open";

    // Check if a seat_type_select filter is already in the URL
    const url = new URL(window.location.href);
    const hasFilter = url.searchParams.has("filters[seat_type_select][id][]");

    if (!hasFilter) {
      const label = CATEGORY_LABELS[category] || "OPEN";
      this.pushEvent("sort", {
        filters: {
          seat_type_select: JSON.stringify({ label: label, value: category }),
        },
      });
    }
  },
};
