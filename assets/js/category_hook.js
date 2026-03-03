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

// Utility: programmatically set a SutraUI Select's value via DOM
export function setSutraSelectValue(selectId, value) {
  const el = document.getElementById(selectId);
  if (!el) return;

  const input = el.querySelector("[data-select-input]");
  const labelEl = el.querySelector("[data-selected-label]");
  const options = el.querySelectorAll('[role="option"]');

  let label = value;
  options.forEach((opt) => {
    if (opt.dataset.value === value) {
      label = opt.dataset.label || opt.textContent.trim();
      opt.setAttribute("aria-selected", "true");
    } else {
      opt.removeAttribute("aria-selected");
    }
  });

  if (input) input.value = value;
  if (labelEl) labelEl.textContent = label;
  el.dataset.selectValue = value;
}

// Index page: category SutraUI Select synced with localStorage.
// This hook goes on the wrapper div; the inner <.select> has its own .Select hook.
export const CategorySelectHook = {
  mounted() {
    // Wait for SutraUI .Select hook to initialize
    requestAnimationFrame(() => {
      const raw = localStorage.getItem("josaa_user_category") || "open";
      const saved = CATEGORY_LABELS[raw] ? raw : "open";
      if (raw !== saved) localStorage.setItem("josaa_user_category", saved);
      setSutraSelectValue("category-select", saved);
    });

    // Listen for SutraUI select changes (fires 'input' on hidden input)
    this._input = this.el.querySelector("[data-select-input]");
    if (this._input) {
      this._onChange = () => {
        const value = this._input.value;
        localStorage.setItem("josaa_user_category", value);
        window.dispatchEvent(
          new CustomEvent("user-category-changed", {
            detail: { category: value },
          })
        );
      };
      this._input.addEventListener("input", this._onChange);
    }

    // Cross-tab sync
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = event.newValue || "open";
        setSutraSelectValue("category-select", val);
      }
    };
    window.addEventListener("storage", this._storageHandler);
  },

  destroyed() {
    if (this._input) this._input.removeEventListener("input", this._onChange);
    window.removeEventListener("storage", this._storageHandler);
  },
};

// Show page: auto-apply saved category as default Select filter
// Also listens for LiveTable LiveSelect changes and saves to localStorage
export const CategoryFilterHook = {
  mounted() {
    const raw = localStorage.getItem("josaa_user_category") || "open";
    // Validate against known keys — cleans up stale JSON from old code
    const category = CATEGORY_LABELS[raw] ? raw : "open";
    if (raw !== category) localStorage.setItem("josaa_user_category", category);

    // Check if a seat_type_select filter is already in the URL
    const url = new URL(window.location.href);
    const hasFilter = url.searchParams.has("filters[seat_type_select][id][]");

    if (!hasFilter) {
      this.pushEvent("sort", {
        filters: {
          seat_type_select: { value: category },
        },
      });
    }

    // Listen for LiveTable LiveSelect changes and save to localStorage
    this.handleEvent("live_select_change", ({ id, text }) => {
      if (id === "seat_type_select" && text) {
        const validCategory = CATEGORY_LABELS[text] ? text : "open";
        localStorage.setItem("josaa_user_category", validCategory);
        window.dispatchEvent(
          new CustomEvent("user-category-changed", {
            detail: { category: validCategory },
          })
        );
      }
    });

    // Cross-tab sync: when another tab changes category, apply filter here too
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = event.newValue || "open";
        const validCategory = CATEGORY_LABELS[val] ? val : "open";
        this.pushEvent("sort", {
          filters: { seat_type_select: { value: validCategory } },
        });
      }
    };
    window.addEventListener("storage", this._storageHandler);
  },

  destroyed() {
    window.removeEventListener("storage", this._storageHandler);
  },
};

// Program show page: sync localStorage category to LiveView via change_category event
export const ProgramCategorySyncHook = {
  mounted() {
    const raw = localStorage.getItem("josaa_user_category") || "open";
    const category = CATEGORY_LABELS[raw] ? raw : "open";
    if (raw !== category) localStorage.setItem("josaa_user_category", category);
    // Only push if not default (open) to avoid unnecessary re-fetch
    if (category !== "open") {
      this.pushEvent("change_category", { seat_type: category });
    }

    this._onCategoryChanged = (e) => {
      this.pushEvent("change_category", {
        seat_type: e.detail?.category || "open",
      });
    };
    window.addEventListener("user-category-changed", this._onCategoryChanged);

    this._onStorage = (e) => {
      if (e.key === "josaa_user_category") {
        this.pushEvent("change_category", {
          seat_type: e.newValue || "open",
        });
      }
    };
    window.addEventListener("storage", this._onStorage);
  },

  destroyed() {
    window.removeEventListener("user-category-changed", this._onCategoryChanged);
    window.removeEventListener("storage", this._onStorage);
  },
};
