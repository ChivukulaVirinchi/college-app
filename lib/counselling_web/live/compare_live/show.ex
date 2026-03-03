defmodule CounsellingWeb.CompareLive.Show do
  use CounsellingWeb, :live_view
  alias Counselling.{Colleges, Programs, Ranks}
  alias CounsellingWeb.RankComponent
  import CounsellingWeb.CollegeLive.Show, only: [nirf_helper: 1]

  @latest_year Josaa.latest_year()

  @seat_type_labels %{
    open: "OPEN",
    obc_ncl: "OBC-NCL",
    sc: "SC",
    st: "ST",
    ews: "EWS",
    open_pwd: "OPEN (PwD)",
    obc_ncl_pwd: "OBC-NCL (PwD)",
    sc_pwd: "SC (PwD)",
    st_pwd: "ST (PwD)",
    ews_pwd: "EWS (PwD)"
  }

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:max_colleges, 4)
      |> assign(:page_title, "Compare Colleges - JOSAA Helper")
      |> assign(:canonical_url, url(~p"/compare"))
      |> assign(
        :meta_description,
        "Compare up to 4 engineering colleges side-by-side. View cutoffs, NIRF rankings, programs and admission chances for your JEE rank side by side."
      )
      |> assign(:latest_year, @latest_year)
      |> assign(:all_colleges, Colleges.list_colleges_summary())

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    college_ids = parse_college_ids(params)
    seat_type = parse_seat_type(params)

    colleges = Colleges.fetch_colleges(college_ids)
    common_programs = Programs.get_common_programs(college_ids)

    cutoff_map =
      if college_ids != [] and common_programs != [] do
        program_ids = Enum.map(common_programs, & &1.id)

        Ranks.get_compare_cutoffs(college_ids, program_ids,
          year: @latest_year,
          seat_type: seat_type
        )
      else
        %{}
      end

    socket =
      socket
      |> assign(:colleges, colleges)
      |> assign(:selected_college_ids, college_ids)
      |> assign(:common_programs, common_programs)
      |> assign(:seat_type, seat_type)
      |> assign(:seat_type_label, Map.get(@seat_type_labels, seat_type, "OPEN"))
      |> assign(:cutoff_map, cutoff_map)
      |> assign(:page_title, "Compare Colleges")

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_college", %{"id" => college_id}, socket) do
    college_id =
      if is_binary(college_id), do: String.to_integer(college_id), else: college_id

    current_ids = socket.assigns.selected_college_ids

    if length(current_ids) < socket.assigns.max_colleges and college_id not in current_ids do
      new_ids = current_ids ++ [college_id]

      socket =
        socket
        |> push_event("update_compare_storage", %{college_ids: new_ids})
        |> push_patch(to: compare_path(new_ids, socket.assigns.seat_type))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Legacy event shape from old search UI
  def handle_event("add_college", %{"college_id" => college_id}, socket) do
    handle_event("add_college", %{"id" => college_id}, socket)
  end

  def handle_event("remove_college", %{"college_id" => college_id}, socket) do
    college_id = String.to_integer(college_id)
    new_ids = Enum.reject(socket.assigns.selected_college_ids, &(&1 == college_id))

    socket =
      socket
      |> push_event("update_compare_storage", %{college_ids: new_ids})
      |> push_patch(to: compare_path(new_ids, socket.assigns.seat_type))

    {:noreply, socket}
  end

  def handle_event("clear_all", _params, socket) do
    socket =
      socket
      |> push_event("update_compare_storage", %{college_ids: []})
      |> push_patch(to: ~p"/compare")

    {:noreply, socket}
  end

  def handle_event("change_seat_type", %{"seat_type" => type}, socket) do
    seat_type = parse_seat_type_atom(type)

    {:noreply,
     push_patch(socket, to: compare_path(socket.assigns.selected_college_ids, seat_type))}
  end

  # -- Helpers ----------------------------------------------------------------

  defp parse_college_ids(params) do
    case Map.get(params, "colleges") do
      nil ->
        []

      ids_string ->
        ids_string
        |> String.split("-")
        |> Enum.map(fn id_str ->
          case Integer.parse(id_str) do
            {id, ""} -> id
            _ -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)
        |> Enum.take(4)
    end
  end

  defp parse_seat_type(params) do
    params |> Map.get("seat_type", "open") |> parse_seat_type_atom()
  end

  defp parse_seat_type_atom(str) when is_binary(str) do
    if Map.has_key?(@seat_type_labels, String.to_existing_atom(str)) do
      String.to_existing_atom(str)
    else
      :open
    end
  rescue
    ArgumentError -> :open
  end

  defp compare_path([], _seat_type), do: ~p"/compare"

  defp compare_path(ids, :open) do
    ~p"/compare?colleges=#{Enum.join(ids, "-")}"
  end

  defp compare_path(ids, seat_type) do
    ~p"/compare?colleges=#{Enum.join(ids, "-")}&seat_type=#{seat_type}"
  end

  defp get_nirf_rank(college, year \\ @latest_year) do
    case Enum.find(college.nirf_rankings, fn ranking -> ranking.year == year end) do
      nil -> nil
      ranking -> ranking.nirf_rank
    end
  end

  defp format_college_class(class) do
    case class do
      :IIT -> "IIT"
      :NIT -> "NIT"
      :IIIT -> "IIIT"
      :GFTI -> "GFTI"
      _ -> "Other"
    end
  end

  # Bold colored badges for the comparison table
  defp type_color(:IIT),
    do:
      "bg-violet-100 text-violet-700 dark:bg-violet-500/15 dark:text-violet-400"

  defp type_color(:NIT),
    do: "bg-blue-100 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400"

  defp type_color(:IIIT),
    do:
      "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-400"

  defp type_color(:GFTI),
    do:
      "bg-orange-100 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400"

  defp type_color(_),
    do: "bg-stone-100 text-stone-600 dark:bg-zinc-800 dark:text-zinc-400"

  # Subtle colored labels for the command palette items
  defp type_color_subtle(:IIT),
    do: "bg-violet-50 text-violet-600 dark:bg-violet-500/10 dark:text-violet-400"

  defp type_color_subtle(:NIT),
    do: "bg-blue-50 text-blue-600 dark:bg-blue-500/10 dark:text-blue-400"

  defp type_color_subtle(:IIIT),
    do: "bg-emerald-50 text-emerald-600 dark:bg-emerald-500/10 dark:text-emerald-400"

  defp type_color_subtle(:GFTI),
    do: "bg-orange-50 text-orange-600 dark:bg-orange-500/10 dark:text-orange-400"

  defp type_color_subtle(_),
    do: "bg-stone-50 text-stone-500 dark:bg-zinc-800 dark:text-zinc-500"
end
