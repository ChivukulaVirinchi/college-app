export const CompareNavHook = {
  mounted() {
    this.storageKey = 'compare_colleges';
    this.updateCounterAndHref();

    // Listen for storage changes
    this._onStorage = (e) => {
      if (e.key === this.storageKey) {
        this.updateCounterAndHref();
      }
    };
    window.addEventListener('storage', this._onStorage);

    // Listen for custom events from compare buttons
    this._onCompareUpdate = () => {
      this.updateCounterAndHref();
      this.animateNavButton();
    };
    document.addEventListener('compare-storage-updated', this._onCompareUpdate);

    // Listen for animation trigger events
    this._onAnimate = () => {
      this.animateNavButton();
    };
    document.addEventListener('animate-compare-nav', this._onAnimate);
  },

  destroyed() {
    window.removeEventListener('storage', this._onStorage);
    document.removeEventListener('compare-storage-updated', this._onCompareUpdate);
    document.removeEventListener('animate-compare-nav', this._onAnimate);
  },

  getCompareColleges() {
    try {
      const parsed = JSON.parse(localStorage.getItem(this.storageKey) || '[]');
      return Array.isArray(parsed) ? parsed.slice(0, 4) : [];
    } catch (error) {
      return [];
    }
  },

  updateCounterAndHref() {
    const compareColleges = this.getCompareColleges();
    const count = compareColleges.length;

    // Update counter display
    const textSpan = this.el.querySelector('.compare-text');
    if (textSpan) {
      textSpan.textContent = count > 0 ? `Compare (${count})` : 'Compare';
    }

    // Update href for navigation
    let href = '/compare';
    if (count > 0) {
      href += '?colleges=' + compareColleges.join('-');
    }
    this.el.href = href;
  },

  animateNavButton() {
    const isDark = document.documentElement.classList.contains('dark');

    this.el.classList.add('animate-bounce');

    this.el.style.transform = 'scale(1.1)';
    this.el.style.transition = 'all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55)';
    this.el.style.backgroundColor = isDark ? 'rgba(245, 158, 11, 0.1)' : 'rgba(217, 119, 6, 0.08)';
    this.el.style.borderColor = isDark ? 'rgba(245, 158, 11, 0.3)' : 'rgba(217, 119, 6, 0.25)';

    this.el.style.boxShadow = isDark
      ? '0 0 16px rgba(245, 158, 11, 0.25)'
      : '0 0 16px rgba(217, 119, 6, 0.2)';

    // Reset after animation
    setTimeout(() => {
      this.el.classList.remove('animate-bounce');
      this.el.style.transform = 'scale(1)';
      this.el.style.backgroundColor = '';
      this.el.style.borderColor = '';
      this.el.style.boxShadow = '';
    }, 800);
  }
};
