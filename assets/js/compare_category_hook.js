// Compare page: seat-type SutraUI Select synced with localStorage.
// This hook goes on the wrapper div; the inner <.select> has its own .Select hook.
// Pushes "change_seat_type" to the LiveView when the user picks a category.

import { setSutraSelectValue } from "./category_hook";

export const CompareCategoryHook = {
  mounted() {
    requestAnimationFrame(() => {
      const saved = localStorage.getItem("josaa_user_category") || "open";
      setSutraSelectValue("compare-category-select", saved);
    });

    // Listen for SutraUI select changes
    this._input = this.el.querySelector("[data-select-input]");
    if (this._input) {
      this._onChange = () => {
        const value = this._input.value;
        localStorage.setItem("josaa_user_category", value);
        this.pushEvent("change_seat_type", { seat_type: value });
        document.dispatchEvent(new CustomEvent("user-category-changed", { detail: { category: value } }));
      };
      this._input.addEventListener("input", this._onChange);
    }

    // Cross-tab sync
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = event.newValue || "open";
        setSutraSelectValue("compare-category-select", val);
        this.pushEvent("change_seat_type", { seat_type: val });
      }
    };
    window.addEventListener("storage", this._storageHandler);
  },

  destroyed() {
    if (this._input) this._input.removeEventListener("input", this._onChange);
    window.removeEventListener("storage", this._storageHandler);
  },
};
