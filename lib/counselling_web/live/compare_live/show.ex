defmodule CounsellingWeb.CompareLive.Show do
  use CounsellingWeb, :live_view
  alias Counselling.{Colleges, Programs, Ranks, Repo}
  alias CounsellingWeb.RankComponent

  @impl true
  def mount(_params, _session, socket) do
    socket = socket |> assign(:search_results, []) |> assign(:max_colleges, 4)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    # Get college IDs from URL parameters (dash-separated)
    college_ids =
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
          # Max 4 colleges
          |> Enum.take(4)
      end

    # Fetch colleges data
    colleges = Colleges.fetch_colleges(college_ids)
    common_programs = Programs.get_common_programs(college_ids)

    socket =
      socket
      |> assign(:colleges, colleges)
      |> assign(:selected_college_ids, college_ids)
      |> assign(:common_programs, common_programs)
      |> assign(:page_title, "Compare Colleges")

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_college", %{"search" => search_term}, socket) do
    search_results = Colleges.search_colleges(search_term)

    socket =
      socket
      |> assign(:search_results, search_results)

  
    {:noreply, socket}
  end

  def handle_event("add_college", %{"college_id" => college_id}, socket) do
    college_id = String.to_integer(college_id)
    current_ids = socket.assigns.selected_college_ids

    if length(current_ids) < socket.assigns.max_colleges and college_id not in current_ids do
      new_ids = current_ids ++ [college_id]
      colleges = Colleges.fetch_colleges(new_ids)
      common_programs = Programs.get_common_programs(new_ids)
      
      # Get the added college for flash message
      added_college = Enum.find(colleges, &(&1.id == college_id))
      college_name = if added_college, do: added_college.name, else: "College"

      socket =
        socket
        |> assign(:selected_college_ids, new_ids)
        |> assign(:colleges, colleges)
        |> assign(:common_programs, common_programs)
        |> push_event("update_compare_storage", %{college_ids: new_ids})
        |> push_event("trigger_compare_animation", %{})
        |> put_flash(:info, "#{college_name} has been added to compare")
        |> push_patch(to: ~p"/compare?colleges=#{Enum.join(new_ids, "-")}")
        

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("remove_college", %{"college_id" => college_id}, socket) do
    college_id = String.to_integer(college_id)
    
    # Get the college name before removing it
    removed_college = Enum.find(socket.assigns.colleges, &(&1.id == college_id))
    college_name = if removed_college, do: removed_college.name, else: "College"
    
    new_ids = Enum.reject(socket.assigns.selected_college_ids, &(&1 == college_id))
    colleges = Colleges.fetch_colleges(new_ids)
    common_programs = Programs.get_common_programs(new_ids)

    path =
      if Enum.empty?(new_ids) do
        ~p"/compare"
      else
        ~p"/compare?colleges=#{Enum.join(new_ids, "-")}"
      end

    socket =
      socket
      |> assign(:selected_college_ids, new_ids)
      |> assign(:colleges, colleges)
      |> assign(:common_programs, common_programs)
      |> push_event("update_compare_storage", %{college_ids: new_ids})
      |> push_event("trigger_compare_animation", %{})
      |> put_flash(:info, "#{college_name} has been removed from compare")
      |> push_patch(to: path)

    {:noreply, socket}
  end

  def handle_event("clear_all", _params, socket) do
    socket =
      socket
      |> assign(:selected_college_ids, [])
      |> assign(:colleges, [])
      |> assign(:common_programs, [])
      |> push_event("update_compare_storage", %{college_ids: []})
      |> put_flash(:info, "All colleges have been removed from compare")
      |> push_patch(to: ~p"/compare")

    {:noreply, socket}
  end

  defp get_college_at_index(colleges, index) do
    Enum.at(colleges, index)
  end

  defp table_data(assigns) do
    ~H"""
    <td class="px-6 py-4 text-center">
      <div class="space-y-1">
        <div class="text-sm font-semibold text-gray-600 dark:text-gray-400">
          <RankComponent.rank_display class="text-sm" rank={@rank_cutoff.opening_rank} /> -
          <RankComponent.rank_display class="text-sm" rank={@rank_cutoff.closing_rank} />
        </div>
        <div class="text-xs text-gray-500 dark:text-gray-400">
          Opening - Closing
        </div>
      </div>
    </td>
    """
  end

  defp get_nirf_rank(college, year \\ 2024) do
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
end
