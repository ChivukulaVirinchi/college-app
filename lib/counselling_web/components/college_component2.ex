defmodule CounsellingWeb.CollegeComponent2 do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: CounsellingWeb.Endpoint, router: CounsellingWeb.Router
  alias CounsellingWeb.RankComponent
  import CounsellingWeb.CollegeLive.Show, only: [nirf_helper: 1]
  # Helper function to get college class colors
  defp class_badge_colors(:IIT), do: "bg-violet-600 text-white"
  defp class_badge_colors(:NIT), do: "bg-blue-600 text-white"
  defp class_badge_colors(:IIIT), do: "bg-green-600 text-white"
  defp class_badge_colors(:GFTI), do: "bg-orange-600 text-white"
  defp class_badge_colors(_), do: "bg-gray-600 text-white"

  # Helper function to get rank badge colors
  defp rank_badge_colors(:IIT),
    do:
      "bg-violet-100 dark:bg-violet-900/30 text-violet-700 dark:text-violet-300 border-violet-200 dark:border-violet-700"

  defp rank_badge_colors(:NIT),
    do:
      "bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 border-blue-200 dark:border-blue-700"

  defp rank_badge_colors(:IIIT),
    do:
      "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 border-green-200 dark:border-green-700"

  defp rank_badge_colors(:GFTI),
    do:
      "bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300 border-orange-200 dark:border-orange-700"

  defp rank_badge_colors(_),
    do:
      "bg-gray-100 dark:bg-gray-900/30 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-700"

  # Helper function to get action button colors
  defp action_button_colors(:IIT),
    do:
      "bg-violet-600 hover:bg-violet-700 dark:bg-violet-700 dark:hover:bg-violet-600 focus:ring-violet-500"

  defp action_button_colors(:NIT),
    do:
      "bg-blue-600 hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-600 focus:ring-blue-500"

  defp action_button_colors(:IIIT),
    do:
      "bg-green-600 hover:bg-green-700 dark:bg-green-700 dark:hover:bg-green-600 focus:ring-green-500"

  defp action_button_colors(:GFTI),
    do:
      "bg-orange-600 hover:bg-orange-700 dark:bg-orange-700 dark:hover:bg-orange-600 focus:ring-orange-500"

  defp action_button_colors(_),
    do:
      "bg-gray-600 hover:bg-gray-700 dark:bg-gray-700 dark:hover:bg-gray-600 focus:ring-gray-500"

  def college_component2(assigns) do
    ~H"""
    <div
      class="bg-white dark:bg-gray-800 shadow-md border border-gray-100 dark:border-gray-700 rounded-xl sm:rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300 group hover:-translate-y-1"
      data-college-name={@record.college.name}
    >
      <div class="relative">
        <%!-- <img
          class="w-full h-32 sm:h-36 object-cover group-hover:scale-105 transition-transform duration-200"
          src="https://img.studyclap.com/img/institute/college/1342_3iitm3.png"
          alt={"#{@record.college.name} campus"}
          loading="lazy"
        /> --%>
        <img
          class="w-full h-32 sm:h-36 object-cover group-hover:scale-105 transition-transform duration-200"
          src={"/#{@record.college.photo_path}"}
          alt={"#{@record.college.name} campus"}
          loading="lazy"
        />
        <div class="absolute top-2 right-2 sm:top-3 sm:right-3">
          <button
            id={"favorite-btn-#{@record.college.id}"}
            class="p-1.5 bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm rounded-full text-gray-400 hover:text-red-500 dark:hover:text-red-400 transition-colors"
            data-id={@record.college.id}
            data-program-id={@record.program.id}
            data-type="college_program"
            phx-hook="FavoriteButton"
            title="Add to favorites"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
              >
              </path>
            </svg>
          </button>
        </div>
        <div class="absolute top-2 left-2 sm:top-3 sm:left-3">
          <span class={"inline-flex items-center px-2 py-1 text-xs font-medium rounded-full #{class_badge_colors(@record.college.class)}"}>
            {@record.college.class}
          </span>
        </div>
      </div>

      <div class="p-4 sm:p-5">
        <div class="flex items-start justify-between mb-4">
          <div class="flex-1 min-w-0 pr-4">
            <div class="flex items-center flex-wrap gap-2 mb-2">
              <.nirf_badge rank={@record.rank} class={@record.college.class} />
            </div>
            <div class="group/title relative mb-3">
              <h3
                class="font-bold text-gray-900 dark:text-white text-base sm:text-lg leading-tight group-hover/title:text-violet-600 dark:group-hover/title:text-violet-400 transition-colors duration-200"
                style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; word-break: break-word;"
                title={@record.college.name}
              >
                {@record.college.name}
              </h3>
            </div>
            <p class="text-sm text-gray-600 dark:text-gray-400 flex items-center leading-relaxed">
              <svg
                class="w-3 h-3 mr-1 flex-shrink-0"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                >
                </path>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                >
                </path>
              </svg>
              {@record.college.location}
            </p>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3 mb-4 text-xs sm:text-sm">
          <div class="text-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <div class="font-bold">
              <RankComponent.rank_display class="text-2xl" rank={@record.opening_rank} />
            </div>
            <div class="text-gray-600 dark:text-gray-400">Opening Rank</div>
          </div>
          <div class="text-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
            <div class="font-bold">
              <RankComponent.rank_display class="text-2xl" rank={@record.closing_rank} />
            </div>
            <div class="text-gray-600 dark:text-gray-400">Closing Rank</div>
          </div>
        </div>

        <div class="space-y-2">
          <.link
            navigate={~p"/colleges/#{@record.college}/programs/#{@record.program}"}
            class={"block w-full px-4 py-3 text-sm font-semibold text-white rounded-lg transition-all duration-200 text-center group/button #{action_button_colors(@record.college.class)} hover:shadow-lg transform hover:scale-[1.02] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-offset-2 dark:focus:ring-offset-gray-800"}
          >
            <span class="flex items-center justify-center">
              <span class="truncate">View Program Details & Cutoffs</span>
              <svg
                class="w-4 h-4 ml-2 transition-transform duration-200 group-hover/button:translate-x-1 flex-shrink-0"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7">
                </path>
              </svg>
            </span>
          </.link>

          <div class="flex gap-2">
            <button
              type="button"
              id={"compare-btn-#{@record.college.id}"}
              phx-hook="CompareButtonHook"
              data-compare-college-id={@record.college.id}
              class="flex-1 px-3 py-2 text-sm font-medium text-emerald-700 dark:text-emerald-300 bg-emerald-100 dark:bg-emerald-900/30 border border-emerald-200 dark:border-emerald-800 rounded-lg hover:bg-emerald-200 dark:hover:bg-emerald-900/50 transition-colors text-center"
            >
              <span class="compare-text">+ Add to Compare</span>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def nirf_badge(assigns) do
    ~H"""
    <span class={"inline-flex items-center px-2 py-1 text-xs font-medium rounded-full border #{rank_badge_colors(@class)}"}>
      NIRF {nirf_helper(@rank)}
    </span>
    """
  end
end
