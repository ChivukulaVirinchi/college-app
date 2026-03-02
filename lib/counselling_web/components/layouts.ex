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
    <div class="min-h-screen bg-stone-50 dark:bg-zinc-950 transition-colors duration-200">
      <header class="sticky top-0 z-50 bg-stone-50/90 dark:bg-zinc-950/90 backdrop-blur-md border-b border-stone-200/80 dark:border-zinc-800/80">
        <nav class="px-4 sm:px-6 lg:px-8 max-w-6xl mx-auto">
          <div class="flex items-center justify-between h-16">
            <!-- Brand -->
            <.link href="/" class="flex items-center gap-2 group">
              <span class="font-serif text-[22px] font-medium tracking-tight text-stone-900 dark:text-zinc-100">
                JOSAA Guide
              </span>
              <span class="w-1.5 h-1.5 rounded-full bg-amber-500 group-hover:scale-150 transition-transform">
              </span>
            </.link>

            <!-- Desktop nav -->
            <div class="hidden md:flex items-center gap-1">
              <.link
                navigate="/colleges"
                class="px-4 py-2 text-[15px] text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
              >
                Colleges
              </.link>
              <.link
                navigate="/programs"
                class="px-4 py-2 text-[15px] text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
              >
                Programs
              </.link>
              <.link
                id="compare-nav-button"
                phx-hook="CompareNavHook"
                navigate="/compare"
                class="relative px-4 py-2 text-[15px] text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
              >
                <span class="compare-text">Compare</span>
              </.link>
            </div>

            <!-- Right side -->
            <div class="flex items-center gap-3">
              <SutraUI.ThemeSwitcher.theme_switcher id="theme-toggle" variant="ghost" />

              <button
                type="button"
                class="md:hidden p-2 text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
                onclick="document.getElementById('mobile-menu').classList.toggle('hidden')"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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

          <!-- Mobile menu -->
          <div
            id="mobile-menu"
            class="hidden md:hidden py-4 border-t border-stone-200 dark:border-zinc-800"
          >
            <div class="space-y-1">
              <.link
                navigate="/colleges"
                class="block px-4 py-2.5 text-sm font-sans text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
              >
                Colleges
              </.link>
              <.link
                navigate="/programs"
                class="block px-4 py-2.5 text-sm font-sans text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
              >
                Programs
              </.link>
              <.link
                id="compare-nav-button-mobile"
                phx-hook="CompareNavHook"
                navigate="/compare"
                class="relative block w-full text-left px-4 py-2.5 text-sm font-sans text-stone-500 dark:text-zinc-400 hover:text-stone-900 dark:hover:text-zinc-100 rounded-lg transition-colors"
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

end
