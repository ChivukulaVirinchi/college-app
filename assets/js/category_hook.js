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

// Extract plain category value from whatever format the hidden input stores.
// SutraUI Select stores plain strings ("open"), but SutraUI LiveSelect stores
// JSON objects ({"label":"OPEN","value":"open"}).
function extractCategoryValue(raw) {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === "object" && parsed.value) {
      // LiveSelect JSON: {"label":"OPEN","value":"open"} or value could be atom-like
      const val = String(parsed.value);
      return CATEGORY_LABELS[val] ? val : null;
    }
  } catch (_) {
    // Not JSON — plain string from SutraUI Select
  }
  return CATEGORY_LABELS[raw] ? raw : null;
}

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

function isClearFiltersClick(event) {
  const target = event.target;
  if (!(target instanceof Element)) return false;

  const clearButton = target.closest(
    '[phx-value-clear_filters="true"], [data-phx-value-clear_filters="true"], [phx-click*="clear_filters"]'
  );
  return !!clearButton;
}

function resetCategoryToOpen() {
  localStorage.setItem("josaa_user_category", "open");
  setSutraSelectValue("category-select", "open");
  window.dispatchEvent(
    new CustomEvent("user-category-changed", {
      detail: { category: "open" },
    })
  );
}

// Index page: category SutraUI Select synced with localStorage.
// This hook goes on the wrapper div; the inner <.select> has its own .Select hook.
export const CategorySelectHook = {
  mounted() {
    console.log("[CategorySelectHook] mounted, el:", this.el.id);

    // Restore saved category after SutraUI .Select hook initializes
    requestAnimationFrame(() => {
      const raw = localStorage.getItem("josaa_user_category") || "open";
      const saved = CATEGORY_LABELS[raw] ? raw : "open";
      if (raw !== saved) localStorage.setItem("josaa_user_category", saved);
      setSutraSelectValue("category-select", saved);
    });

    // Listen for SutraUI Select changes via document-level event delegation.
    // SutraUI .Select fires 'input' on [data-select-input] hidden inputs.
    // Listen on both 'input' and 'change' for robustness.
    this._onChange = (e) => {
      const input = e.target;
      if (!input.hasAttribute("data-select-input")) return;
      if (!this.el.contains(input)) return;
      const value = extractCategoryValue(input.value);
      console.log("[CategorySelectHook] select changed:", input.value, "→", value);
      if (value) {
        localStorage.setItem("josaa_user_category", value);
        window.dispatchEvent(
          new CustomEvent("user-category-changed", {
            detail: { category: value },
          })
        );
      }
    };
    document.addEventListener("input", this._onChange);
    document.addEventListener("change", this._onChange);

    this._onClearFilters = (event) => {
      if (isClearFiltersClick(event)) resetCategoryToOpen();
    };
    document.addEventListener("click", this._onClearFilters, true);

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
    document.removeEventListener("input", this._onChange);
    document.removeEventListener("change", this._onChange);
    document.removeEventListener("click", this._onClearFilters, true);
    window.removeEventListener("storage", this._storageHandler);
  },
};

// Show page: auto-apply saved category as default Select filter
// Also listens for LiveTable LiveSelect changes and saves to localStorage
export const CategoryFilterHook = {
  mounted() {
    const raw = localStorage.getItem("josaa_user_category") || "open";
    console.log("[CategoryFilterHook] mounted, localStorage raw:", raw);
    const category = CATEGORY_LABELS[raw] ? raw : "open";
    if (raw !== category) localStorage.setItem("josaa_user_category", category);

    // Check if a seat_type_select filter is already in the URL
    const url = new URL(window.location.href);
    const hasFilter = url.searchParams.has("filters[seat_type_select][id][]");
    console.log("[CategoryFilterHook] hasFilter:", hasFilter, "applying:", category);

    if (!hasFilter) {
      this.applyCategoryFilter(category);
    }

    // Listen for LiveSelect hidden input changes.
    // SutraUI LiveSelect fires 'input' and 'change' on [data-live-select-input].
    // The value is JSON like {"label":"OPEN","value":"open"}.
    this._onLiveSelectChange = (e) => {
      const input = e.target;
      if (!input.hasAttribute("data-live-select-input")) return;
      const value = extractCategoryValue(input.value);
      console.log("[CategoryFilterHook] LiveSelect changed:", input.value, "→", value);
      if (value) {
        localStorage.setItem("josaa_user_category", value);
        window.dispatchEvent(
          new CustomEvent("user-category-changed", {
            detail: { category: value },
          })
        );
      }
    };
    document.addEventListener("input", this._onLiveSelectChange);
    document.addEventListener("change", this._onLiveSelectChange);

    this._onClearFilters = (event) => {
      if (!isClearFiltersClick(event)) return;

      event.preventDefault();
      event.stopImmediatePropagation();
      resetCategoryToOpen();
      this.applyDefaultFilters();
    };
    document.addEventListener("click", this._onClearFilters, true);

    this._onPageLoadingStop = () => {
      this.applyOpenIfMissing();
    };
    window.addEventListener("phx:page-loading-stop", this._onPageLoadingStop);

    // Cross-tab sync
    this._storageHandler = (event) => {
      if (event.key === "josaa_user_category") {
        const val = event.newValue || "open";
        const validCategory = CATEGORY_LABELS[val] ? val : "open";
        this.applyCategoryFilter(validCategory);
      }
    };
    window.addEventListener("storage", this._storageHandler);
  },

  applyCategoryFilter(category) {
    this.pushEvent("sort", {
      filters: { seat_type_select: { value: category } },
    });
  },

  applyOpenIfMissing() {
    const nextUrl = new URL(window.location.href);
    if (!nextUrl.searchParams.has("filters[seat_type_select][id][]")) {
      this.applyCategoryFilter("open");
    }
  },

  applyDefaultFilters() {
    this.pushEvent("sort", {
      search: "",
      filters: {
        seat_type_select: { value: "open" },
        gender_filter: "true",
        female_filter: "false",
        hs: "false",
        all_india: "false",
        os: "false",
      },
    });
  },

  destroyed() {
    window.removeEventListener("storage", this._storageHandler);
    window.removeEventListener("phx:page-loading-stop", this._onPageLoadingStop);
    document.removeEventListener("click", this._onClearFilters, true);
    document.removeEventListener("input", this._onLiveSelectChange);
    document.removeEventListener("change", this._onLiveSelectChange);
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

    this._onClearFilters = (event) => {
      if (isClearFiltersClick(event)) resetCategoryToOpen();
    };
    document.addEventListener("click", this._onClearFilters, true);

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
    document.removeEventListener("click", this._onClearFilters, true);
  },
};
