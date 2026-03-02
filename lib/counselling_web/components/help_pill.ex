defmodule CounsellingWeb.HelpPill do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def help_pill(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="HelpPill"
      class={[
        "flex items-start gap-2.5 px-4 py-3 rounded-lg bg-blue-50/80 dark:bg-blue-900/15 border border-blue-100 dark:border-blue-800/30 text-sm text-blue-700 dark:text-blue-300",
        @class
      ]}
    >
      <svg
        class="w-4 h-4 mt-0.5 shrink-0 text-blue-400 dark:text-blue-500"
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path
          fill-rule="evenodd"
          d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z"
          clip-rule="evenodd"
        />
      </svg>
      <div class="flex-1 leading-relaxed">
        {render_slot(@inner_block)}
      </div>
      <button
        type="button"
        class="shrink-0 p-0.5 rounded-full text-blue-400 hover:text-blue-600 dark:text-blue-500 dark:hover:text-blue-300 transition-colors"
        data-dismiss-help
        title="Dismiss"
      >
        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </button>
    </div>
    """
  end
end
