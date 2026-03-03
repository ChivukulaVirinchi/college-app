// Initialize favorites in localStorage
function initFavorites() {
  if (!localStorage.getItem('counselling_favorites')) {
    localStorage.setItem('counselling_favorites', JSON.stringify({
      colleges: [], programs: [], college_programs: []
    }));
  }
}

// Get favorites from localStorage
function getFavorites() {
  return JSON.parse(localStorage.getItem('counselling_favorites') || '{"colleges":[],"programs":[],"college_programs":[]}');
}

// Save favorites to localStorage
function saveFavorites(favorites) {
  localStorage.setItem('counselling_favorites', JSON.stringify(favorites));
}

// Check if item is favorited
function isFavorited(id, type, programId = null) {
  const favorites = getFavorites();
  const numId = parseInt(id);
  
  if (type === 'college') return favorites.colleges.includes(numId);
  if (type === 'program') return favorites.programs.includes(numId);
  if (type === 'college_program') return favorites.college_programs.includes(`${id}_${programId}`);
  return false;
}

// Toggle favorite status
function toggleFavorite(id, type, programId = null) {
  const favorites = getFavorites();
  const numId = parseInt(id);
  
  if (type === 'college') {
    const index = favorites.colleges.indexOf(numId);
    index > -1 ? favorites.colleges.splice(index, 1) : favorites.colleges.push(numId);
  } else if (type === 'program') {
    const index = favorites.programs.indexOf(numId);
    index > -1 ? favorites.programs.splice(index, 1) : favorites.programs.push(numId);
  } else if (type === 'college_program') {
    const key = `${id}_${programId}`;
    const index = favorites.college_programs.indexOf(key);
    index > -1 ? favorites.college_programs.splice(index, 1) : favorites.college_programs.push(key);
  }
  
  saveFavorites(favorites);
}

// Update button visual state
function updateButtonState(button) {
  const id = button.getAttribute('data-id');
  const type = button.getAttribute('data-type');
  const programId = button.getAttribute('data-program-id');
  const svg = button.querySelector('svg');
  const textSpan = button.querySelector('.favorite-text');
  
  if (!id || !type || !svg) return;
  
  const favorited = isFavorited(id, type, programId);
  
  if (favorited) {
    svg.setAttribute('fill', 'currentColor');
    button.classList.add('text-red-500');
    button.classList.remove('text-gray-400', 'text-white', 'text-violet-700', 'dark:text-violet-300');
    if (textSpan) textSpan.textContent = 'Favorited';
  } else {
    svg.setAttribute('fill', 'none');
    button.classList.remove('text-red-500');
    if (button.id?.includes('overlay')) {
      button.classList.add('text-white');
    } else {
      button.classList.add('text-gray-400');
    }
    if (textSpan) textSpan.textContent = 'Favorite';
  }
}

// Container hook - initializes favorites and updates all buttons
export const FavoritesHook = {
  mounted() {
    initFavorites();
    this.el.querySelectorAll('button[data-id][data-type]').forEach(updateButtonState);
  },
  updated() {
    this.el.querySelectorAll('button[data-id][data-type]').forEach(updateButtonState);
  }
};

// Individual button hook
export const FavoriteButton = {
  mounted() {
    this.el.addEventListener('click', this.handleClick.bind(this));
    updateButtonState(this.el);
  },
  updated() {
    updateButtonState(this.el);
  },
  destroyed() {
    this.el.removeEventListener('click', this.handleClick);
  },
  handleClick(e) {
    e.preventDefault();
    const id = this.el.getAttribute('data-id');
    const type = this.el.getAttribute('data-type');
    const programId = this.el.getAttribute('data-program-id');
    
    if (id && type) {
      toggleFavorite(id, type, programId);
      updateButtonState(this.el);
    }
  }
};

// Share Hook for sharing functionality
export const ShareHook = {
  mounted() {
    this.handleClick = this.handleClick.bind(this);
    this.el.addEventListener('click', this.handleClick);
  },

  destroyed() {
    this.el.removeEventListener('click', this.handleClick);
  },

  async handleClick(e) {
    e.preventDefault();
    const title = this.el.getAttribute('data-title');
    const url = this.el.getAttribute('data-url');
    
    if (navigator.share) {
      try {
        await navigator.share({ title, url });
      } catch (err) {
        this.copyToClipboard(url);
      }
    } else {
      this.copyToClipboard(url);
    }
  },

  async copyToClipboard(text) {
    try {
      await navigator.clipboard.writeText(text);
      this.showToast('Link copied to clipboard!');
    } catch (err) {
      console.error('Failed to copy:', err);
      this.showToast('Failed to copy link');
    }
  },

  showToast(message) {
    const toast = document.createElement('div');
    toast.textContent = message;
    toast.className = 'fixed top-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg z-50 transition-opacity';
    document.body.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      setTimeout(() => document.body.removeChild(toast), 300);
    }, 2000);
  }
};

// Charts Hook for Chart.js integration
export const ChartsHook = {
  mounted() {
    this.initChart();
  },
  
  updated() {
    this.destroyChart();
    this.initChart();
  },
  
  destroyed() {
    this.destroyChart();
  },
  
  destroyChart() {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  },
  
  initChart() {
    const canvas = this.el;
    const chartType = canvas.getAttribute('data-chart-type');
    
    if (!window.Chart) {
      console.log('Chart.js not available');
      return;
    }
    
    try {
      if (chartType === 'rank-trends') {
        this.initRankTrendsChart(canvas);
      } else {
        this.initNirfRankingsChart(canvas);
      }
    } catch (error) {
      console.error('Chart initialization error:', error);
    }
  },
  
  initNirfRankingsChart(canvas) {
    const rankingsData = canvas.getAttribute('data-rankings');
    
    if (!rankingsData) {
      console.log('No rankings data available');
      return;
    }
    
    const rankings = JSON.parse(rankingsData);
    if (rankings.length === 0) {
      console.log('No rankings data available');
      return;
    }

    const years = rankings.map(r => r.year).sort();
    const ranks = years.map(year => {
      const ranking = rankings.find(r => r.year === year);
      return ranking ? ranking.rank : null;
    });

    // Check for dark mode
    const isDarkMode = document.documentElement.classList.contains('dark');
    const gridColor = isDarkMode ? 'rgba(156, 163, 175, 0.2)' : 'rgba(0, 0, 0, 0.1)';
    const textColor = isDarkMode ? 'rgb(156, 163, 175)' : 'rgb(75, 85, 99)';

    // Compute a nice stepSize so we only get integer ticks
    const validRanks = ranks.filter(r => r !== null);
    const minRank = Math.min(...validRanks);
    const maxRank = Math.max(...validRanks);
    const range = maxRank - minRank;
    const stepSize = range <= 10 ? 1 : range <= 50 ? 5 : range <= 200 ? 10 : 25;

    this.chart = new Chart(canvas, {
      type: 'line',
      data: {
        labels: years,
        datasets: [{
          label: 'NIRF Ranking',
          data: ranks,
          borderColor: 'rgb(217, 119, 6)',
          backgroundColor: 'rgba(217, 119, 6, 0.08)',
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: 'rgb(217, 119, 6)',
          pointBorderColor: isDarkMode ? 'rgb(24, 24, 27)' : '#fff',
          pointBorderWidth: 2,
          pointRadius: 6,
          pointHoverRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: function(context) {
                return 'Rank: ' + Math.round(context.parsed.y);
              }
            }
          }
        },
        scales: {
          y: {
            reverse: true,
            beginAtZero: false,
            title: {
              display: true,
              text: 'Rank (Lower is Better)',
              color: textColor
            },
            grid: {
              color: gridColor
            },
            ticks: {
              color: textColor,
              stepSize: stepSize,
              precision: 0,
              callback: function(value) {
                return Number.isInteger(value) ? value : '';
              }
            }
          },
          x: {
            title: {
              display: true,
              text: 'Year',
              color: textColor
            },
            grid: {
              color: gridColor
            },
            ticks: {
              color: textColor
            }
          }
        }
      }
    });
  }
};

