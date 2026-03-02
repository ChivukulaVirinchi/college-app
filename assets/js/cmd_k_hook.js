// Cmd+K (Mac) / Ctrl+K (Windows/Linux) to open the college search dialog.
export const CmdKHook = {
  mounted() {
    this._handler = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === "k") {
        e.preventDefault();
        const dialog = document.getElementById("college-search-dialog");
        if (dialog) {
          dialog.dispatchEvent(new Event("phx:show-dialog"));
        }
      }
    };
    window.addEventListener("keydown", this._handler);
  },

  destroyed() {
    window.removeEventListener("keydown", this._handler);
  },
};
