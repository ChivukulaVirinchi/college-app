// Cutoff trends chart for college-program page.
// Shows opening → closing rank range as filled bands across years.
// Filtered by seat_type from localStorage (josaa_user_category).

const QUOTA_COLORS = {
  all_india:   { line: 'rgb(59, 130, 246)',  fill: 'rgba(59, 130, 246, 0.12)',  label: 'All India' },
  home_state:  { line: 'rgb(34, 197, 94)',   fill: 'rgba(34, 197, 94, 0.12)',   label: 'Home State' },
  other_state: { line: 'rgb(249, 115, 22)',  fill: 'rgba(249, 115, 22, 0.12)',  label: 'Other State' },
};

const FEMALE_QUOTA_COLORS = {
  all_india:   { line: 'rgb(236, 72, 153)',  fill: 'rgba(236, 72, 153, 0.12)',  label: 'All India' },
  home_state:  { line: 'rgb(168, 85, 247)',  fill: 'rgba(168, 85, 247, 0.12)',  label: 'Home State' },
  other_state: { line: 'rgb(244, 114, 182)', fill: 'rgba(244, 114, 182, 0.12)', label: 'Other State' },
};

const CATEGORY_LABELS = {
  open: 'OPEN', obc_ncl: 'OBC-NCL', sc: 'SC', st: 'ST', ews: 'EWS',
  open_pwd: 'OPEN (PwD)', obc_ncl_pwd: 'OBC-NCL (PwD)',
  sc_pwd: 'SC (PwD)', st_pwd: 'ST (PwD)', ews_pwd: 'EWS (PwD)',
};

export const CutoffChartHook = {
  mounted() {
    this.allData = JSON.parse(this.el.dataset.allCutoffs || '[]');
    if (!this.allData.length || !window.Chart) return;

    this.canvas = this.el.querySelector('canvas');
    this.chart = null;
    this.showFemale = false;

    // Bind toggle
    const toggle = this.el.querySelector('[data-gender-toggle]');
    if (toggle) {
      toggle.addEventListener('click', () => {
        this.showFemale = !this.showFemale;
        toggle.textContent = this.showFemale ? 'Showing: Female Only' : 'Showing: Gender Neutral';
        toggle.classList.toggle('bg-pink-100', this.showFemale);
        toggle.classList.toggle('dark:bg-pink-900/20', this.showFemale);
        toggle.classList.toggle('text-pink-700', this.showFemale);
        toggle.classList.toggle('dark:text-pink-400', this.showFemale);
        toggle.classList.toggle('border-pink-300', this.showFemale);
        toggle.classList.toggle('dark:border-pink-700', this.showFemale);
        toggle.classList.toggle('bg-stone-100', !this.showFemale);
        toggle.classList.toggle('dark:bg-zinc-800', !this.showFemale);
        toggle.classList.toggle('text-stone-600', !this.showFemale);
        toggle.classList.toggle('dark:text-zinc-400', !this.showFemale);
        toggle.classList.toggle('border-stone-300', !this.showFemale);
        toggle.classList.toggle('dark:border-zinc-700', !this.showFemale);
        this.render();
      });
    }

    this.category = localStorage.getItem('josaa_user_category') || 'open';
    this.render();

    this._onStorage = (e) => {
      if (e.key === 'josaa_user_category') {
        this.category = e.newValue || 'open';
        this.render();
      }
    };
    window.addEventListener('storage', this._onStorage);

    this._onCategoryChange = (e) => {
      this.category = e.detail?.category || localStorage.getItem('josaa_user_category') || 'open';
      this.render();
    };
    document.addEventListener('user-category-changed', this._onCategoryChange);
  },

  destroyed() {
    if (this.chart) this.chart.destroy();
    window.removeEventListener('storage', this._onStorage);
    document.removeEventListener('user-category-changed', this._onCategoryChange);
  },

  render() {
    if (this.chart) this.chart.destroy();

    const gender = this.showFemale ? 'female' : 'gender_neutral';
    const filtered = this.allData.filter(
      rc => rc.seat_type === this.category && rc.gender === gender
    );

    if (!filtered.length) {
      this.renderEmpty();
      return;
    }

    const years = [...new Set(filtered.map(rc => rc.year))].sort();
    const isDark = document.documentElement.classList.contains('dark');
    const gridColor = isDark ? 'rgba(161, 161, 170, 0.08)' : 'rgba(120, 113, 108, 0.08)';
    const textColor = isDark ? 'rgb(161, 161, 170)' : 'rgb(120, 113, 108)';

    // Group by quota
    const groups = {};
    filtered.forEach(rc => {
      if (!groups[rc.quota]) groups[rc.quota] = [];
      groups[rc.quota].push(rc);
    });

    const datasets = [];
    const quotaOrder = ['all_india', 'home_state', 'other_state'];
    const palette = this.showFemale ? FEMALE_QUOTA_COLORS : QUOTA_COLORS;
    const presentQuotas = [];

    for (const quota of quotaOrder) {
      const data = groups[quota];
      if (!data) continue;

      const colors = palette[quota] || { line: 'rgb(120,113,108)', fill: 'rgba(120,113,108,0.1)', label: quota };
      const fillColor = isDark ? colors.fill.replace('0.12', '0.08') : colors.fill;
      presentQuotas.push({ quota, colors });

      // Closing rank (primary line)
      datasets.push({
        label: `${colors.label} — Closing`,
        data: years.map(y => { const r = data.find(d => d.year === y); return r ? r.closing_rank : null; }),
        borderColor: colors.line,
        backgroundColor: fillColor,
        borderWidth: 2.5,
        fill: false,
        tension: 0.3,
        pointRadius: 4,
        pointHoverRadius: 7,
        pointBackgroundColor: colors.line,
        pointBorderColor: isDark ? 'rgb(24, 24, 27)' : '#fff',
        pointBorderWidth: 2,
        spanGaps: true,
        order: 1,
      });

      // Opening rank (fills area between opening and closing)
      datasets.push({
        label: `${colors.label} — Opening`,
        data: years.map(y => { const r = data.find(d => d.year === y); return r ? r.opening_rank : null; }),
        borderColor: colors.line.replace('rgb', 'rgba').replace(')', ', 0.4)'),
        backgroundColor: fillColor,
        borderWidth: 1,
        borderDash: [4, 3],
        fill: '-1', // fill to previous dataset (closing rank line)
        tension: 0.3,
        pointRadius: 2.5,
        pointHoverRadius: 5,
        pointBackgroundColor: colors.line.replace('rgb', 'rgba').replace(')', ', 0.5)'),
        pointBorderColor: isDark ? 'rgb(24, 24, 27)' : '#fff',
        pointBorderWidth: 1.5,
        spanGaps: true,
        order: 2,
      });
    }

    // Update subtitle
    const subtitle = this.el.querySelector('[data-chart-subtitle]');
    if (subtitle) {
      const gLabel = this.showFemale ? 'Female Only' : 'Gender Neutral';
      subtitle.textContent = `${CATEGORY_LABELS[this.category] || this.category} · ${gLabel} · Opening → Closing range by quota`;
    }

    // Update toolbar legends dynamically
    const legendsContainer = this.el.querySelector('[data-chart-legends]');
    if (legendsContainer) {
      legendsContainer.innerHTML = presentQuotas.map(({ colors }) =>
        `<span class="flex items-center gap-1.5">
          <span class="w-3 h-3 rounded-full" style="background:${colors.line}20;border:2px solid ${colors.line}"></span>
          ${colors.label}
        </span>`
      ).join('');
    }

    this.chart = new Chart(this.canvas, {
      type: 'line',
      data: { labels: years, datasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'bottom',
            labels: {
              color: textColor,
              usePointStyle: true,
              pointStyle: 'line',
              padding: 18,
              font: { size: 11, family: 'system-ui' },
              boxWidth: 24,
              filter: (item) => item.text.includes('Closing'),
            },
          },
          tooltip: {
            backgroundColor: isDark ? 'rgb(39, 39, 42)' : '#fff',
            titleColor: isDark ? 'rgb(228, 228, 231)' : 'rgb(28, 25, 23)',
            titleFont: { size: 13, weight: '600' },
            bodyColor: isDark ? 'rgb(161, 161, 170)' : 'rgb(120, 113, 108)',
            bodyFont: { size: 12 },
            borderColor: isDark ? 'rgb(63, 63, 70)' : 'rgb(228, 225, 220)',
            borderWidth: 1,
            cornerRadius: 10,
            padding: { top: 10, bottom: 10, left: 14, right: 14 },
            displayColors: true,
            boxWidth: 10,
            boxHeight: 10,
            boxPadding: 4,
            callbacks: {
              label(ctx) {
                const val = Math.round(ctx.parsed.y).toLocaleString();
                return ` ${ctx.dataset.label}: ${val}`;
              },
            },
          },
        },
        scales: {
          y: {
            reverse: true,
            beginAtZero: false,
            title: {
              display: true,
              text: 'Rank',
              color: textColor,
              font: { size: 11, weight: '500' },
              padding: { bottom: 8 },
            },
            grid: { color: gridColor, drawBorder: false },
            border: { display: false },
            ticks: {
              color: textColor,
              font: { size: 11 },
              precision: 0,
              maxTicksLimit: 8,
              callback(v) { return Number.isInteger(v) ? v.toLocaleString() : ''; },
            },
          },
          x: {
            title: { display: false },
            grid: { display: false },
            border: { display: false },
            ticks: { color: textColor, font: { size: 11 } },
          },
        },
        interaction: { intersect: false, mode: 'index' },
        layout: { padding: { top: 4, right: 8 } },
      },
    });
  },

  renderEmpty() {
    const subtitle = this.el.querySelector('[data-chart-subtitle]');
    if (subtitle) {
      const gLabel = this.showFemale ? 'Female Only' : 'Gender Neutral';
      subtitle.textContent = `No data for ${CATEGORY_LABELS[this.category] || this.category} · ${gLabel}`;
    }
    const ctx = this.canvas.getContext('2d');
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
  },
};
