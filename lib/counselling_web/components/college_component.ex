defmodule CounsellingWeb.CollegeComponent do
  use CounsellingWeb, :html

  def college_component(assigns) do
    ~H"""
    <.card class="group overflow-hidden gap-0! hover:-translate-y-1 hover:shadow-xl transition-all duration-300">
      <:header class="relative h-28 overflow-hidden p-0! gap-0! block!">
        <img
          class="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 ease-out"
          src={"/#{@record.college.photo_path}"}
          alt={@record.college.name}
          loading="lazy"
        />
        <%!-- Gradient overlay --%>
        <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-black/20 to-transparent" />
        <%!-- Badges + favorite overlaid --%>
        <div class="absolute top-2.5 left-2.5 right-2.5 z-10 flex items-start justify-between">
          <span class={[
            "px-2 py-0.5 text-[10px] font-bold tracking-wider uppercase text-white rounded-full backdrop-blur-sm",
            class_badge_color(@record.college.class)
          ]}>
            {@record.college.class}
          </span>
          <button
            type="button"
            id={"favorite-overlay-#{@record.college.id}"}
            class="relative z-20 p-1.5 text-white bg-black/30 backdrop-blur-sm rounded-full transition-colors"
            data-id={@record.college.id}
            data-type="college"
            phx-hook="FavoriteButton"
            title="Add to favorites"
          >
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
              />
            </svg>
          </button>
        </div>
      </:header>

      <:content class="pt-4 pb-2 px-4 sm:px-5">
        <%!-- College name: the HERO --%>
        <.link navigate={~p"/colleges/#{@record.college}"} class="block group/name">
          <h3
            class="font-serif text-xl sm:text-[1.35rem] text-stone-900 dark:text-zinc-50 leading-snug font-medium group-hover/name:text-amber-700 dark:group-hover/name:text-amber-400 transition-colors"
            style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;"
          >
            {@record.college.name}
          </h3>
        </.link>

        <%!-- Location · NIRF rank --%>
        <p class="mt-1.5 text-sm text-stone-500 dark:text-zinc-400">
          {@record.college.location}
          <span class="mx-1 text-stone-300 dark:text-zinc-600">&middot;</span>
          <span class="font-medium text-stone-600 dark:text-zinc-300">
            NIRF {nirf_helper(@record.rank)}
          </span>
        </p>

        <%!-- Year · Programs --%>
        <p class="mt-1 text-xs text-stone-400 dark:text-zinc-500">
          Est. {@record.college.established_year}
          <span class="mx-1">&middot;</span>
          {@record.programs} programs
        </p>
      </:content>

      <:footer class="flex items-center gap-2 px-4 sm:px-5 pb-4 pt-2">
        <.button
          variant="primary"
          size="sm"
          navigate={~p"/colleges/#{@record.college}"}
        >
          View Details
        </.button>
        <button
          type="button"
          id={"compare-btn-#{@record.college.id}"}
          phx-hook="CompareButtonHook"
          data-compare-college-id={@record.college.id}
          class="inline-flex items-center justify-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-lg border transition-colors text-stone-600 dark:text-zinc-400 border-stone-200 dark:border-zinc-700 bg-transparent hover:bg-stone-100 dark:hover:bg-zinc-800"
        >
          <span class="compare-text">+ Compare</span>
        </button>
      </:footer>
    </.card>
    """
  end

  defp class_badge_color(:IIT), do: "bg-violet-600/90"
  defp class_badge_color(:NIT), do: "bg-blue-600/90"
  defp class_badge_color(:IIIT), do: "bg-emerald-600/90"
  defp class_badge_color(:GFTI), do: "bg-orange-600/90"
  defp class_badge_color(_), do: "bg-amber-500/90"

  defp nirf_helper(500), do: "—"
  defp nirf_helper(250), do: "201–300"
  defp nirf_helper(175), do: "151–200"
  defp nirf_helper(125), do: "101–150"
  defp nirf_helper(rank), do: "#{rank}"
end
