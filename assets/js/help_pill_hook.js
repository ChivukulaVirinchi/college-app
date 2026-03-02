export const HelpPillHook = {
  mounted() {
    const key = `help_dismissed_${this.el.id}`;
    if (localStorage.getItem(key)) {
      this.el.remove();
      return;
    }

    const btn = this.el.querySelector("[data-dismiss-help]");
    if (btn) {
      btn.addEventListener("click", () => {
        localStorage.setItem(key, "true");
        this.el.style.opacity = "0";
        this.el.style.transform = "translateY(-4px)";
        this.el.style.transition = "all 0.2s ease-out";
        setTimeout(() => this.el.remove(), 200);
      });
    }
  },
};
