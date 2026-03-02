defmodule CounsellingWeb.ProgramComponent do
  use CounsellingWeb, :html

  def program_component(assigns) do
    ~H"""
    <.card class="group h-full hover:-translate-y-1 hover:shadow-xl transition-all duration-300">
      <:content class="flex-1">
        <%!-- Degree badge + duration --%>
        <div class="flex items-center gap-2 mb-3">
          <span class={[
            "px-2.5 py-0.5 text-[11px] font-bold tracking-wide uppercase text-white rounded-full",
            degree_color(@record.degree_type)
          ]}>
            {degree_abbr(@record.degree_type)}
          </span>
          <span class="text-xs text-stone-400 dark:text-zinc-500">
            {@record.duration} years
          </span>
          <span
            :if={dual_degree?(@record.degree_type)}
            class="px-2 py-0.5 text-[10px] font-medium text-amber-700 dark:text-amber-300 bg-amber-100 dark:bg-amber-900/30 border border-amber-200 dark:border-amber-700 rounded-full"
          >
            Dual
          </span>
        </div>

        <%!-- Program name: the HERO --%>
        <.link navigate={~p"/programs/#{@record}"} class="block group/name">
          <h3
            class="font-serif text-xl sm:text-[1.35rem] text-stone-900 dark:text-zinc-50 leading-snug font-medium group-hover/name:text-violet-700 dark:group-hover/name:text-violet-400 transition-colors"
            style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;"
            title={@record.name}
          >
            {@record.name}
          </h3>
        </.link>

        <%!-- College count --%>
        <p class="mt-2 text-sm text-stone-500 dark:text-zinc-400">
          <span class="font-medium text-stone-600 dark:text-zinc-300">{@record.college_count}</span>
          {if @record.college_count == 1, do: "college", else: "colleges"} offering this program
        </p>
      </:content>

      <:footer class="flex items-center">
        <.button
          variant="primary"
          size="sm"
          navigate={~p"/programs/#{@record}"}
        >
          View Colleges
        </.button>
      </:footer>
    </.card>
    """
  end

  defp degree_color("Bachelor of Technology"), do: "bg-violet-600"
  defp degree_color("Bachelor and Master of Technology (Dual Degree)"), do: "bg-blue-600"
  defp degree_color("Bachelor of Science"), do: "bg-emerald-600"

  defp degree_color("Bachelor of Science and Master of Science (Dual Degree)"),
    do: "bg-orange-600"

  defp degree_color("Bachelor of Architecture"), do: "bg-pink-600"
  defp degree_color("Integrated B. Tech. and MBA"), do: "bg-indigo-600"
  defp degree_color("Integrated B. Tech. and M. Tech."), do: "bg-purple-600"
  defp degree_color("B. Tech / B. Tech (Hons.)"), do: "bg-red-600"
  defp degree_color("Integrated Master of Technology"), do: "bg-amber-600"
  defp degree_color("Bachelor of Technology and MBA (Dual Degree)"), do: "bg-teal-600"
  defp degree_color(_), do: "bg-stone-600"

  defp degree_abbr("Bachelor of Technology"), do: "B.Tech"
  defp degree_abbr("Bachelor and Master of Technology (Dual Degree)"), do: "B.Tech + M.Tech"
  defp degree_abbr("Bachelor of Science"), do: "B.Sc"
  defp degree_abbr("Bachelor of Science and Master of Science (Dual Degree)"), do: "B.Sc + M.Sc"
  defp degree_abbr("Bachelor of Architecture"), do: "B.Arch"
  defp degree_abbr("Integrated B. Tech. and MBA"), do: "B.Tech + MBA"
  defp degree_abbr("Integrated B. Tech. and M. Tech."), do: "B.Tech + M.Tech"
  defp degree_abbr("B. Tech / B. Tech (Hons.)"), do: "B.Tech (Hons.)"
  defp degree_abbr("Integrated Master of Technology"), do: "I.M.Tech"
  defp degree_abbr("Bachelor of Technology and MBA (Dual Degree)"), do: "B.Tech + MBA"
  defp degree_abbr(degree), do: degree || "Unknown"

  defp dual_degree?(dt) when is_binary(dt),
    do: String.contains?(dt, ["Dual Degree", "Integrated"])

  defp dual_degree?(_), do: false
end
