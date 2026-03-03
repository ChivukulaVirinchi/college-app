defmodule CounsellingWeb.EmptyState do
  use Phoenix.Component

  @messages %{
    colleges: %{
      title: "No colleges found",
      description: "Try adjusting your rank or filters to see more results."
    },
    college_programs: %{
      title: "No programs found",
      description: "No program cutoffs are available for the selected filters."
    },
    programs: %{
      title: "No programs found",
      description: "Try adjusting your filters to see more results."
    },
    program_colleges: %{
      title: "No colleges found",
      description: "No colleges match the current filters for this program."
    },
    cutoffs: %{
      title: "No cutoff data available",
      description: "No cutoff records found for the selected filters."
    }
  }

  def empty_state(assigns) do
    msg = Map.get(@messages, assigns[:context], @messages.colleges)
    assigns = assigns |> Map.put(:msg, msg) |> Map.put_new(:__changed__, nil)

    ~H"""
    <div class="flex flex-col items-center justify-center py-16 text-center">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        class="size-12 text-stone-300 dark:text-zinc-600 mb-4"
        aria-hidden="true"
      >
        <circle cx="11" cy="11" r="8" />
        <path d="m21 21-4.3-4.3" />
        <path d="M8 11h6" />
      </svg>
      <h3 class="text-lg font-medium text-stone-600 dark:text-zinc-400">
        {@msg.title}
      </h3>
      <p class="mt-1 text-sm text-stone-400 dark:text-zinc-500 max-w-sm">
        {@msg.description}
      </p>
    </div>
    """
  end
end
