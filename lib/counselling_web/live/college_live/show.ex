defmodule CounsellingWeb.CollegeLive.Show do
  use CounsellingWeb, :live_view

  alias Counselling.Colleges

  @impl true
  def mount(params, _session, socket) do
    [id_str | _] = String.split(params["college"], "-")
    id = String.to_integer(id_str)

    socket =
      socket
      |> assign(:college, Colleges.get_college_by_id!(id))
      |> assign(filters: %{category: []})

    {:ok,
     stream(
       socket,
       :programs,
       Colleges.get_college_program_rank_data_by_id(10, socket.assigns.filters)
     )}
  end

  @impl true
  def handle_params(params, _, socket) do
    options = %{
      category: params["category"] || ["gender_neutral"],
      sort_by: params["sort_by"] || "name",
      sort_order: params["sort_order"] || "asc"
    }

    {:noreply,
     socket
     |> assign(:advanced_rank, 2000)
     |> assign(:mains_rank, 38000)
     |> assign(:filters, options)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> stream(
       :programs,
       Colleges.get_college_program_rank_data_by_id(socket.assigns.college.id, options),
       reset: true
     )}
  end

  @impl true
  def handle_event("filter", filters, socket) do
    filters =
      filters
      |> Map.delete("_target")
      |> update_checkbox_filters("category")
      |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

    updated_filters = Map.merge(socket.assigns.filters, filters)

    {:noreply,
     socket
     |> push_patch(to: ~p"/colleges/#{socket.assigns.college}?#{build_query(updated_filters)}")}
  end

  def update_checkbox_filters(filters, key) do
    case filters[key] do
      nil -> Map.put(filters, key, [])
      values when is_list(values) -> Map.put(filters, key, values)
      value -> Map.put(filters, key, [value])
    end
  end

  def build_query(filters) do
    filters
    |> Enum.filter(fn
      {_, v} when is_binary(v) -> v != ""
      {_, v} when is_list(v) -> v != []
      _ -> true
    end)
    |> Enum.map(fn
      {"class", values} -> {"class", Enum.map(values, &String.to_existing_atom/1)}
      other -> other
    end)
    |> Enum.into(%{})
  end

  def get_sort_order(sort_order) do
    case sort_order do
      "asc" -> "desc"
      "desc" -> "asc"
    end
  end

  def get_rank_color(closing_rank, advanced_rank, mains_rank, class) do
    rank =
      cond do
        class == :IIT -> advanced_rank
        true -> mains_rank
      end

    upper_value = closing_rank + closing_rank * 0.1
    lower_value = closing_rank - closing_rank * 0.1

    cond do
      lower_value <= rank and rank <= upper_value ->
        "text-yellow-600 bg-yellow-100"

      rank <= lower_value ->
        "text-green-600 bg-green-200/70"

      rank >= upper_value ->
        "text-red-600 bg-red-200/80"

      true ->
        ""
    end
  end

  defp page_title(:show), do: "Show College"
  defp page_title(:edit), do: "Edit College"
  defp process_quota(:all_india), do: "AI"
  defp process_quota(:home_state), do: "HS"
  defp process_quota(:other_state), do: "OS"

  defp process_category(:gender_neutral), do: "Gender Neutral"
  defp process_category(:female), do: "Female Only"
  defp process_category(_), do: "Gender Neutral"
end
