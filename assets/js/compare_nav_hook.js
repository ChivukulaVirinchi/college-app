export const CompareNavHook = {
  mounted() {
    this.storageKey = 'compare_colleges';
    this.updateCounterAndHref();
    
    // Listen for storage changes
    window.addEventListener('storage', (e) => {
      if (e.key === this.storageKey) {
        this.updateCounterAndHref();
      }
    });
    
    // Listen for custom events from compare buttons
    document.addEventListener('compare-storage-updated', () => {
      this.updateCounterAndHref();
      this.animateNavButton();
    });
    
    // Listen for animation trigger events
    document.addEventListener('animate-compare-nav', () => {
      this.animateNavButton();
    });
  },

  getCompareColleges() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey) || '[]');
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
    // Add vibration/bounce animation with better effects
    this.el.classList.add('animate-bounce');
    
    // Add multiple scale and color effects
    this.el.style.transform = 'scale(1.1)';
    this.el.style.transition = 'all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55)';
    this.el.style.backgroundColor = 'rgba(139, 92, 246, 0.1)';
    this.el.style.borderColor = 'rgba(139, 92, 246, 0.3)';
    
    // Add glow effect
    this.el.style.boxShadow = '0 0 20px rgba(139, 92, 246, 0.4)';
    
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