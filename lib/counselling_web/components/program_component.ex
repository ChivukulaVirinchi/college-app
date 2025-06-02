defmodule CounsellingWeb.ProgramComponent do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: CounsellingWeb.Endpoint, router: CounsellingWeb.Router
  alias Counselling.Programs
  import Ecto.Query, warn: false
  alias Counselling.Repo

  # Helper function to get degree badge colors based on degree type
  defp degree_badge_colors("Bachelor of Technology"), do: "bg-violet-600 text-white"

  defp degree_badge_colors("Bachelor and Master of Technology (Dual Degree)"),
    do: "bg-blue-600 text-white"

  defp degree_badge_colors("Bachelor of Science"), do: "bg-green-600 text-white"

  defp degree_badge_colors("Bachelor of Science and Master of Science (Dual Degree)"),
    do: "bg-orange-600 text-white"

  defp degree_badge_colors("Bachelor of Architecture"), do: "bg-pink-600 text-white"
  defp degree_badge_colors("Integrated B. Tech. and MBA"), do: "bg-indigo-600 text-white"
  defp degree_badge_colors("Integrated B. Tech. and M. Tech."), do: "bg-purple-600 text-white"
  defp degree_badge_colors("B. Tech / B. Tech (Hons.)"), do: "bg-red-600 text-white"
  defp degree_badge_colors("Integrated Master of Technology"), do: "bg-yellow-600 text-white"

  defp degree_badge_colors("Bachelor of Technology and MBA (Dual Degree)"),
    do: "bg-teal-600 text-white"

  defp degree_badge_colors(_), do: "bg-gray-600 text-white"

  # Helper function to get duration badge colors
  defp duration_badge_colors("Bachelor of Technology"),
    do:
      "bg-violet-100 dark:bg-violet-900/30 text-violet-700 dark:text-violet-300 border-violet-200 dark:border-violet-700"

  defp duration_badge_colors("Bachelor and Master of Technology (Dual Degree)"),
    do:
      "bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 border-blue-200 dark:border-blue-700"

  defp duration_badge_colors("Bachelor of Science"),
    do:
      "bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 border-green-200 dark:border-green-700"

  defp duration_badge_colors("Bachelor of Science and Master of Science (Dual Degree)"),
    do:
      "bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300 border-orange-200 dark:border-orange-700"

  defp duration_badge_colors("Bachelor of Architecture"),
    do:
      "bg-pink-100 dark:bg-pink-900/30 text-pink-700 dark:text-pink-300 border-pink-200 dark:border-pink-700"

  defp duration_badge_colors("Integrated B. Tech. and MBA"),
    do:
      "bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 border-indigo-200 dark:border-indigo-700"

  defp duration_badge_colors("Integrated B. Tech. and M. Tech."),
    do:
      "bg-purple-100 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 border-purple-200 dark:border-purple-700"

  defp duration_badge_colors("B. Tech / B. Tech (Hons.)"),
    do:
      "bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300 border-red-200 dark:border-red-700"

  defp duration_badge_colors("Integrated Master of Technology"),
    do:
      "bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300 border-yellow-200 dark:border-yellow-700"

  defp duration_badge_colors("Bachelor of Technology and MBA (Dual Degree)"),
    do:
      "bg-teal-100 dark:bg-teal-900/30 text-teal-700 dark:text-teal-300 border-teal-200 dark:border-teal-700"

  defp duration_badge_colors(_),
    do:
      "bg-gray-100 dark:bg-gray-900/30 text-gray-700 dark:text-gray-300 border-gray-200 dark:border-gray-700"

  # Helper function to get action button colors
  defp action_button_colors("Bachelor of Technology"),
    do:
      "bg-violet-600 hover:bg-violet-700 dark:bg-violet-700 dark:hover:bg-violet-600 focus:ring-violet-500"

  defp action_button_colors("Bachelor and Master of Technology (Dual Degree)"),
    do:
      "bg-blue-600 hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-600 focus:ring-blue-500"

  defp action_button_colors("Bachelor of Science"),
    do:
      "bg-green-600 hover:bg-green-700 dark:bg-green-700 dark:hover:bg-green-600 focus:ring-green-500"

  defp action_button_colors("Bachelor of Science and Master of Science (Dual Degree)"),
    do:
      "bg-orange-600 hover:bg-orange-700 dark:bg-orange-700 dark:hover:bg-orange-600 focus:ring-orange-500"

  defp action_button_colors("Bachelor of Architecture"),
    do:
      "bg-pink-600 hover:bg-pink-700 dark:bg-pink-700 dark:hover:bg-pink-600 focus:ring-pink-500"

  defp action_button_colors("Integrated B. Tech. and MBA"),
    do:
      "bg-indigo-600 hover:bg-indigo-700 dark:bg-indigo-700 dark:hover:bg-indigo-600 focus:ring-indigo-500"

  defp action_button_colors("Integrated B. Tech. and M. Tech."),
    do:
      "bg-purple-600 hover:bg-purple-700 dark:bg-purple-700 dark:hover:bg-purple-600 focus:ring-purple-500"

  defp action_button_colors("B. Tech / B. Tech (Hons.)"),
    do: "bg-red-600 hover:bg-red-700 dark:bg-red-700 dark:hover:bg-red-600 focus:ring-red-500"

  defp action_button_colors("Integrated Master of Technology"),
    do:
      "bg-yellow-600 hover:bg-yellow-700 dark:bg-yellow-700 dark:hover:bg-yellow-600 focus:ring-yellow-500"

  defp action_button_colors("Bachelor of Technology and MBA (Dual Degree)"),
    do:
      "bg-teal-600 hover:bg-teal-700 dark:bg-teal-700 dark:hover:bg-teal-600 focus:ring-teal-500"

  defp action_button_colors(_),
    do:
      "bg-gray-600 hover:bg-gray-700 dark:bg-gray-700 dark:hover:bg-gray-600 focus:ring-gray-500"

  # Helper function to get degree abbreviation
  defp degree_abbreviation("Bachelor of Technology"), do: "B.Tech"

  defp degree_abbreviation("Bachelor and Master of Technology (Dual Degree)"),
    do: "B.Tech + M.Tech"

  defp degree_abbreviation("Bachelor of Science"), do: "B.Sc"

  defp degree_abbreviation("Bachelor of Science and Master of Science (Dual Degree)"),
    do: "B.Sc + M.Sc"

  defp degree_abbreviation("Bachelor of Architecture"), do: "B.Arch"
  defp degree_abbreviation("Integrated B. Tech. and MBA"), do: "B.Tech + MBA"
  defp degree_abbreviation("Integrated B. Tech. and M. Tech."), do: "B.Tech + M.Tech"
  defp degree_abbreviation("B. Tech / B. Tech (Hons.)"), do: "B.Tech (Hons.)"
  defp degree_abbreviation("Integrated Master of Technology"), do: "I.M.Tech"
  defp degree_abbreviation("Bachelor of Technology and MBA (Dual Degree)"), do: "B.Tech + MBA"
  defp degree_abbreviation(degree), do: degree

  # Helper function to determine if it's a dual degree
  defp is_dual_degree?(degree_type) do
    String.contains?(degree_type || "", ["Dual Degree", "Integrated", "+"])
  end

  def program_component(assigns) do
    assigns =
      Map.put(
        assigns,
        :count,
        Programs.list_colleges(assigns.record.id)
        |> exclude(:select)
        |> exclude(:order_by)
        |> select([c], count(c.id))
        |> Repo.one()
      )

    ~H"""
    <div class="bg-white dark:bg-gray-800 shadow-md border border-gray-100 dark:border-gray-700 rounded-xl sm:rounded-2xl overflow-hidden hover:shadow-xl transition-all duration-300 group hover:-translate-y-1">
      <div class="p-5 sm:p-6">
        <div class="flex items-start justify-between mb-4">
          <div class="flex-1 min-w-0 pr-4">
            <div class="flex items-center flex-wrap gap-2 mb-3">
              <span class={"inline-flex items-center px-3 py-1 text-xs font-semibold rounded-full #{degree_badge_colors(@record.degree_type || "")}"}>
                {degree_abbreviation(@record.degree_type || "Unknown")}
              </span>
              <span class={"inline-flex items-center px-3 py-1 text-xs font-medium rounded-full border #{duration_badge_colors(@record.degree_type || "")}"}>
                {@record.duration || "N/A"} Years
              </span>
              <%= if is_dual_degree?(@record.degree_type) do %>
                <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-md bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-700">
                  Dual Degree
                </span>
              <% end %>
            </div>
            <div class="group/title relative mb-3">
              <h3
                class="font-bold text-gray-900 dark:text-white text-base sm:text-lg leading-tight group-hover/title:text-violet-600 dark:group-hover/title:text-violet-400 transition-colors duration-200"
                style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; word-break: break-word;"
                title={@record.name}
              >
                {@record.name || "Unnamed Program"}
              </h3>
            </div>
            <p class="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
              {@count} colleges offering this program
            </p>
          </div>
          <div class="flex-shrink-0">
            <div class="flex items-center justify-center w-16 h-16 rounded-xl bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600">
              <div class="text-center">
                <div class="text-lg font-bold text-gray-900 dark:text-white">
                  {@count}
                </div>
                <div class="text-xs text-gray-500 dark:text-gray-400">Colleges</div>
              </div>
            </div>
          </div>
        </div>

        <div class="flex items-center justify-between mb-5 px-4 py-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg border border-gray-100 dark:border-gray-600">
          <div class="flex items-center min-w-0">
            <svg
              class="w-4 h-4 mr-2 text-gray-500 dark:text-gray-400 flex-shrink-0"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"
              >
              </path>
            </svg>
            <span class="text-sm font-medium text-gray-700 dark:text-gray-300 truncate">
              {@record.degree_type || "Unknown Degree"}
            </span>
          </div>
          
        </div>

        <div class="space-y-3">
          <.link
            navigate={~p"/programs/#{@record}"}
            class={"block w-full px-4 py-3 text-sm font-semibold text-white rounded-lg transition-all duration-200 text-center group/button #{action_button_colors(@record.degree_type || "")} hover:shadow-lg transform hover:scale-[1.02] active:scale-[0.98] focus:outline-none focus:ring-2 focus:ring-offset-2 dark:focus:ring-offset-gray-800"}
          >
            <span class="flex items-center justify-center">
              <span class="truncate">View Colleges Offering This Program</span>
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
        </div>
      </div>
    </div>
    """
  end
end
