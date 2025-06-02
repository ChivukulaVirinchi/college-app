export const CompareButtonHook = {
  mounted() {
    this.storageKey = 'compare_colleges';
    this.collegeId = parseInt(this.el.dataset.compareCollegeId);
    
    // Update button state on mount
    this.updateButtonState();
    
    // Add click handler
    this.el.addEventListener('click', (e) => {
      e.preventDefault();
      this.handleClick();
    });
  },

  handleClick() {
    const compareColleges = this.getCompareColleges();
    const isInCompare = compareColleges.includes(this.collegeId);
    
    if (isInCompare) {
      this.removeFromCompare();
    } else {
      this.addToCompare();
    }
  },

  addToCompare() {
    const compareColleges = this.getCompareColleges();
    
    if (!compareColleges.includes(this.collegeId)) {
      compareColleges.push(this.collegeId);
      this.saveCompareColleges(compareColleges);
      this.updateButtonState();
      this.showFlashMessage('added');
    }
  },

  removeFromCompare() {
    const compareColleges = this.getCompareColleges();
    const updatedColleges = compareColleges.filter(id => id !== this.collegeId);
    
    this.saveCompareColleges(updatedColleges);
    this.updateButtonState();
    this.showFlashMessage('removed');
  },

  getCompareColleges() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey) || '[]');
    } catch (error) {
      return [];
    }
  },

  saveCompareColleges(colleges) {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(colleges));
      document.dispatchEvent(new CustomEvent('compare-storage-updated'));
    } catch (error) {
      console.error('Error saving to localStorage:', error);
    }
  },

  updateButtonState() {
    const compareColleges = this.getCompareColleges();
    const isInCompare = compareColleges.includes(this.collegeId);
    
    const textSpan = this.el.querySelector('.compare-text') || this.el;
    
    // Remove all color classes first
    this.el.classList.remove(
      'text-emerald-700', 'dark:text-emerald-300', 
      'bg-emerald-100', 'dark:bg-emerald-900/30',
      'border-emerald-200', 'dark:border-emerald-800',
      'hover:bg-emerald-200', 'dark:hover:bg-emerald-900/50',
      'text-red-700', 'dark:text-red-300',
      'bg-red-100', 'dark:bg-red-900/30',
      'border-red-200', 'dark:border-red-800',
      'hover:bg-red-200', 'dark:hover:bg-red-900/50'
    );
    
    if (isInCompare) {
      // Red styling for remove
      this.el.classList.add(
        'text-red-700', 'dark:text-red-300',
        'bg-red-100', 'dark:bg-red-900/30',
        'border-red-200', 'dark:border-red-800',
        'hover:bg-red-200', 'dark:hover:bg-red-900/50'
      );
      textSpan.textContent = 'Remove from Compare';
    } else {
      // Green styling for add
      this.el.classList.add(
        'text-emerald-700', 'dark:text-emerald-300', 
        'bg-emerald-100', 'dark:bg-emerald-900/30',
        'border-emerald-200', 'dark:border-emerald-800',
        'hover:bg-emerald-200', 'dark:hover:bg-emerald-900/50'
      );
      textSpan.textContent = '+ Add to Compare';
    }
  },

  showFlashMessage(action) {
    // Get college name from the nearest college card
    const collegeCard = this.el.closest('[data-college-name]');
    const collegeName = collegeCard ? collegeCard.dataset.collegeName : 'College';
    
    const message = action === 'added' 
      ? `${collegeName} has been added to compare`
      : `${collegeName} has been removed from compare`;
    
    this.createFlashElement(message);
    this.animateCompareNav();
  },

  createFlashElement(message) {
    // Remove any existing flash
    const existingFlash = document.querySelector('.compare-flash-message');
    if (existingFlash) {
      existingFlash.remove();
    }

    // Determine if it's an add or remove action
    const isAdd = message.includes('added');
    const bgColor = isAdd ? 'bg-green-50 dark:bg-green-900/30' : 'bg-blue-50 dark:bg-blue-900/30';
    const borderColor = isAdd ? 'border-green-200 dark:border-green-800' : 'border-blue-200 dark:border-blue-800';
    const iconColor = isAdd ? 'text-green-400' : 'text-blue-400';
    const textColor = isAdd ? 'text-green-800 dark:text-green-200' : 'text-blue-800 dark:text-blue-200';
    
    const icon = isAdd 
      ? '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>'
      : '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>';

    // Create flash element
    const flash = document.createElement('div');
    flash.className = `compare-flash-message fixed top-20 right-4 z-50 max-w-sm p-4 ${bgColor} border ${borderColor} rounded-lg shadow-lg backdrop-blur-sm`;
    flash.style.transform = 'translateX(100%)';
    flash.style.opacity = '0';
    flash.style.transition = 'all 0.3s ease-in-out';
    
    flash.innerHTML = `
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <svg class="w-5 h-5 ${iconColor}" fill="currentColor" viewBox="0 0 20 20">
            ${icon}
          </svg>
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium ${textColor}">${message}</p>
        </div>
      </div>
    `;

    document.body.appendChild(flash);

    // Animate in
    requestAnimationFrame(() => {
      flash.style.transform = 'translateX(0)';
      flash.style.opacity = '1';
    });

    // Remove after 3 seconds
    setTimeout(() => {
      flash.style.transform = 'translateX(100%)';
      flash.style.opacity = '0';
      setTimeout(() => flash.remove(), 300);
    }, 3000);
  },

  animateCompareNav() {
    // Dispatch custom event to animate nav buttons
    document.dispatchEvent(new CustomEvent('animate-compare-nav'));
  }
};