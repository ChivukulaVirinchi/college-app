defmodule CounsellingWeb.Dropdown do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  def dropdown(assigns) do
    ~H"""
    <div
      phx-focus-wrap
      id="dropdown"
      class="max-w-0"
      phx-click={
        JS.toggle_class("hidden", to: "#visible-content")
        |> JS.toggle_class("rotate-180", to: "#dropdown .chevron", time: 300)
        |> JS.toggle(
          to: "#visible-content",
          in: {"ease-in-out  duration-1000", "translate-y-0", "-translate-y-6"},
          out: {"ease-in-out opacity-0 duration-300", "translate-y-0", "translate-y-6"},
          time: 300
        )
      }
    >
      <button
        type="button"
        class="py-3 px-4 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-300/70 bg-white text-gray-800 shadow-sm hover:bg-gray-50 focus:outline-none focus:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none ark:bg-neutral-800 ark:border-neutral-700 ark:text-white ark:hover:bg-neutral-700 ark:focus:bg-neutral-700"
      >
        Actions
        <svg
          class="transition-all duration-300 size-4 chevron"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="m6 9 6 6 6-6" />
        </svg>
      </button>

      <div
        id="visible-content"
        class="hidden absolute max-w-sm duration-500 bg-white mt-2 shadow-md rounded-lg p-1 space-y-0.5  ark:bg-neutral-800 ark:border ark:border-neutral-700 ark:divide-neutral-700"
      >
        <div class="divide-y divide-gray-300/70 py-2">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end
end
