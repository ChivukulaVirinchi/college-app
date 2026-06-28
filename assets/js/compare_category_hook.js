// Compare page: seat-type SutraUI Select synced with localStorage.
// This hook goes on the wrapper div; the inner <.select> has its own .Select hook.
// Pushes "change_seat_type" to the LiveView when the user picks a category.

import { setSutraSelectValue } from "./category_hook";

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

function validCategory(value) {
  return CATEGORY_LABELS[value] ? value : "open";
}

export const CompareCategoryHook = {
  mounted() {
    requestAnimationFrame(() => {
      const current = validCategory(this.el.dataset.currentSeatType || "open");
      const saved = validCategory(localStorage.getItem("josaa_user_category") || "open");
      const initial = this.el.dataset.hasSeatTypeParam === "true" ? current : saved;

      localStorage.setItem("josaa_user_category", initial);
      setSutraSelectValue("compare-category-select", initial);

      if (initial !== current) {
        this.pushEvent("change_seat_type", { seat_type: initial });
      }
    });

    // Listen for SutraUI select changes (fires 'input' on hidden input)
    this._input = this.el.querySelector("[data-select-input]");
    if (this._input) {
      this._onChange = () => {
        const value = validCategory(this._input.value);
        localStorage.setItem("josaa_user_category", value);
        this.pushEvent("change_seat_type", { seat_type: value });
        document.dispatchEvent(new CustomEvent("user-category-changed", { detail: { category: value } }));
      };
      this._input.addEventListener("input", this._onChange);
    }

    // Cross-tab sync
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = validCategory(event.newValue || "open");
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
