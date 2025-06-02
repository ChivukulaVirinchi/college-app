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
    if (textSpan) textSpan.textContent = 'Remove from Favorites';
  } else {
    svg.setAttribute('fill', 'none');
    button.classList.remove('text-red-500');
    if (button.id?.includes('overlay')) {
      button.classList.add('text-white');
    } else {
      button.classList.add('text-gray-400');
    }
    if (textSpan) textSpan.textContent = 'Add to Favorites';
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

    this.chart = new Chart(canvas, {
      type: 'line',
      data: {
        labels: years,
        datasets: [{
          label: 'NIRF Ranking',
          data: ranks,
          borderColor: 'rgb(139, 92, 246)',
          backgroundColor: 'rgba(139, 92, 246, 0.1)',
          borderWidth: 3,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: 'rgb(139, 92, 246)',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 6,
          pointHoverRadius: 8
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { 
          legend: { display: false } 
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
              stepSize: 1
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
  },
  
  initRankTrendsChart(canvas) {
    const rankCutoffsData = canvas.getAttribute('data-rank-cutoffs');
    
    if (!rankCutoffsData) {
      console.log('No rank cutoffs data available');
      return;
    }
    
    const rankCutoffs = JSON.parse(rankCutoffsData);
    
    if (!rankCutoffs || rankCutoffs.length === 0) {
      console.log('No rank cutoffs available');
      return;
    }
    
    // Extract unique years and sort them
    const years = [...new Set(rankCutoffs.map(rc => rc.year))].sort();
    
    // Check for dark mode
    const isDarkMode = document.documentElement.classList.contains('dark');
    const gridColor = isDarkMode ? 'rgba(156, 163, 175, 0.2)' : 'rgba(0, 0, 0, 0.1)';
    const textColor = isDarkMode ? 'rgb(156, 163, 175)' : 'rgb(75, 85, 99)';
    
    // Group data by quota and category
    const groupedData = {};
    rankCutoffs.forEach(rc => {
      const key = `${rc.quota}_${rc.category}`;
      if (!groupedData[key]) {
        groupedData[key] = [];
      }
      groupedData[key].push(rc);
    });
    
    // Sort each group by year
    Object.keys(groupedData).forEach(key => {
      groupedData[key].sort((a, b) => a.year - b.year);
    });
    
    // Determine if college has all_india OR (home_state + other_state)
    const hasAllIndia = rankCutoffs.some(rc => rc.quota === 'all_india');
    const hasStateQuotas = rankCutoffs.some(rc => rc.quota === 'home_state' || rc.quota === 'other_state');
    
    const datasets = [];
    
    if (hasAllIndia) {
      // All India colleges (2 categories × 2 rank types = 4 lines)
      if (groupedData['all_india_gender_neutral']) {
        const data = groupedData['all_india_gender_neutral'];
        datasets.push({
          label: 'All India Gender Neutral - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(59, 130, 246)',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'All India Gender Neutral - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(59, 130, 246)',
          backgroundColor: 'rgba(59, 130, 246, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
      
      if (groupedData['all_india_female']) {
        const data = groupedData['all_india_female'];
        datasets.push({
          label: 'All India Female Only - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(236, 72, 153)',
          backgroundColor: 'rgba(236, 72, 153, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'All India Female Only - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(236, 72, 153)',
          backgroundColor: 'rgba(236, 72, 153, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
    } else if (hasStateQuotas) {
      // State colleges (4 categories × 2 rank types = 8 lines)
      if (groupedData['home_state_gender_neutral']) {
        const data = groupedData['home_state_gender_neutral'];
        datasets.push({
          label: 'Home State Gender Neutral - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(34, 197, 94)',
          backgroundColor: 'rgba(34, 197, 94, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'Home State Gender Neutral - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(34, 197, 94)',
          backgroundColor: 'rgba(34, 197, 94, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
      
      if (groupedData['home_state_female']) {
        const data = groupedData['home_state_female'];
        datasets.push({
          label: 'Home State Female Only - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(16, 185, 129)',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'Home State Female Only - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(16, 185, 129)',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
      
      if (groupedData['other_state_gender_neutral']) {
        const data = groupedData['other_state_gender_neutral'];
        datasets.push({
          label: 'Other State Gender Neutral - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(249, 115, 22)',
          backgroundColor: 'rgba(249, 115, 22, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'Other State Gender Neutral - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(249, 115, 22)',
          backgroundColor: 'rgba(249, 115, 22, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
      
      if (groupedData['other_state_female']) {
        const data = groupedData['other_state_female'];
        datasets.push({
          label: 'Other State Female Only - Opening',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.opening_rank : null;
          }),
          borderColor: 'rgb(239, 68, 68)',
          backgroundColor: 'rgba(239, 68, 68, 0.1)',
          borderWidth: 3,
          borderDash: [],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
        
        datasets.push({
          label: 'Other State Female Only - Closing',
          data: years.map(year => {
            const item = data.find(d => d.year === year);
            return item ? item.closing_rank : null;
          }),
          borderColor: 'rgb(239, 68, 68)',
          backgroundColor: 'rgba(239, 68, 68, 0.1)',
          borderWidth: 3,
          borderDash: [5, 5],
          fill: false,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6,
          spanGaps: true
        });
      }
    }

    if (datasets.length === 0) {
      console.log('No data available for chart');
      return;
    }

    this.chart = new Chart(canvas, {
      type: 'line',
      data: {
        labels: years,
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { 
          legend: { 
            display: true,
            position: 'top',
            labels: {
              color: textColor,
              usePointStyle: true,
              padding: 15
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
              color: textColor
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
        },
        interaction: {
          intersect: false,
          mode: 'index'
        }
      }
    });
  }
};

