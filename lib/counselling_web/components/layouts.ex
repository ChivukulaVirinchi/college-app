defmodule CounsellingWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use CounsellingWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 dark:bg-gray-900 transition-colors duration-200">
      <header class="sticky top-0 z-50 bg-white/95 dark:bg-gray-900/95 backdrop-blur-sm border-b border-gray-200 dark:border-gray-700">
        <nav class="px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <!-- Logo and Brand -->
            <div class="flex items-center">
              <.link navigate="/" class="flex items-center space-x-3 group">
                <div class="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-violet-600 to-purple-600 rounded-xl group-hover:scale-105 transition-transform">
                  <svg
                    class="w-6 h-6 text-white"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"
                    >
                    </path>
                  </svg>
                </div>
                <div class="hidden sm:block">
                  <h1 class="text-xl font-bold text-gray-900 dark:text-white">JOSAA Guide</h1>
                  <p class="text-xs text-gray-600 dark:text-gray-400">
                    Engineering College Counselling
                  </p>
                </div>
              </.link>
            </div>

            <div class="hidden md:flex items-center space-x-1">
              <.link
                navigate="/colleges"
                class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                Colleges
              </.link>
              <.link
                navigate="/programs"
                class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                Programs
              </.link>
              <.link
                id="compare-nav-button"
                phx-hook="CompareNavHook"
                navigate="/compare"
                class="relative px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                <span class="compare-text">Compare</span>
              </.link>
            </div>

            <div class="flex items-center space-x-3">
              <.theme_toggle />

              <button
                type="button"
                class="md:hidden p-2 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                onclick="document.getElementById('mobile-menu').classList.toggle('hidden')"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 6h16M4 12h16M4 18h16"
                  >
                  </path>
                </svg>
              </button>
            </div>
          </div>

          <div
            id="mobile-menu"
            class="hidden md:hidden py-4 border-t border-gray-200 dark:border-gray-700"
          >
            <div class="space-y-2">
              <.link
                patch="/colleges"
                class="block px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                Colleges
              </.link>
              <.link
                patch="/programs"
                class="block px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                Programs
              </.link>
              <.link
                id="compare-nav-button-mobile"
                phx-hook="CompareNavHook"
                navigate="/compare"
                class="relative block w-full text-left px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-violet-600 dark:hover:text-violet-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                <span class="compare-text">Compare</span>
              </.link>
            </div>
          </div>
        </nav>
      </header>

      <main class="flex-1">
        {render_slot(@inner_block)}
      </main>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="fixed top-20 right-4 z-50 w-full max-w-sm space-y-2">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("Connection Lost")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex items-center bg-gray-100 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700">
      <div
        id="theme-slider"
        class="absolute w-1/3 h-full bg-white dark:bg-gray-700 rounded-md shadow-sm border border-gray-300 dark:border-gray-600 transition-all duration-200 ease-in-out"
        style="left: 0;"
      />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="relative flex items-center justify-center p-2 w-1/3 transition-colors z-10 hover:text-violet-600 dark:hover:text-violet-400 text-gray-600 dark:text-gray-400"
        data-theme-button="system"
        title="System theme"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="relative flex items-center justify-center p-2 w-1/3 transition-colors z-10 hover:text-violet-600 dark:hover:text-violet-400 text-gray-600 dark:text-gray-400"
        data-theme-button="light"
        title="Light theme"
      >
        <.icon name="hero-sun-micro" class="size-4" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="relative flex items-center justify-center p-2 w-1/3 transition-colors z-10 hover:text-violet-600 dark:hover:text-violet-400 text-gray-600 dark:text-gray-400"
        data-theme-button="dark"
        title="Dark theme"
      >
        <.icon name="hero-moon-micro" class="size-4" />
      </button>
    </div>

    <script>
      (() => {
        const THEME_KEY = 'phx:theme';

        const getSystemTheme = () => {
          return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
        };

        const getCurrentTheme = () => {
          return localStorage.getItem(THEME_KEY) || 'system';
        };

        const getEffectiveTheme = (theme = getCurrentTheme()) => {
          return theme === 'system' ? getSystemTheme() : theme;
        };

        const updateThemeToggle = () => {
          const currentTheme = getCurrentTheme();
          const slider = document.getElementById('theme-slider');
          const buttons = document.querySelectorAll('[data-theme-button]');

          if (!slider || !buttons.length) return;

          const positions = {
            'system': '0%',
            'light': '33.333%',
            'dark': '66.666%'
          };

          slider.style.left = positions[currentTheme] || positions['system'];

          buttons.forEach(btn => {
            const buttonTheme = btn.dataset.themeButton;
            const isActive = buttonTheme === currentTheme;

            if (isActive) {
              btn.classList.add('text-violet-600', 'dark:text-violet-400');
              btn.classList.remove('text-gray-600', 'dark:text-gray-400');
            } else {
              btn.classList.remove('text-violet-600', 'dark:text-violet-400');
              btn.classList.add('text-gray-600', 'dark:text-gray-400');
            }
          });
        };

        const applyTheme = (theme = getCurrentTheme()) => {
          const html = document.documentElement;
          const effectiveTheme = getEffectiveTheme(theme);

          html.classList.toggle('dark', effectiveTheme === 'dark');
        };

        const handleThemeChange = (event) => {
          const theme = event.detail.theme;
          localStorage.setItem(THEME_KEY, theme);
          applyTheme(theme);
          updateThemeToggle();
        };

        const initTheme = () => {
          const savedTheme = getCurrentTheme();
          applyTheme(savedTheme);

          setTimeout(updateThemeToggle, 10);
        };

        window.addEventListener('phx:set-theme', handleThemeChange);

        window.addEventListener('storage', (e) => {
          if (e.key === THEME_KEY) {
            const newTheme = e.newValue || 'system';
            applyTheme(newTheme);
            updateThemeToggle();
          }
        });

        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
          const currentTheme = getCurrentTheme();
          if (currentTheme === 'system') {
            applyTheme('system');

          }
        });

        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', initTheme);
        } else {
          initTheme();
        }
      })();
    </script>
    """
  end
end
