defmodule CounsellingWeb.ProgramLive.Show do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges

  @impl true
  def mount(params, _session, socket) do
    [id_str | _] = String.split(params["slug"], "-")
    id = String.to_integer(id_str)

    socket =
      socket
      |> assign(:filters, %{})
      |> assign(:program, Colleges.get_program!(id))
      |> stream(:colleges, Colleges.get_program_data(id))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    options = %{
      sort_by: params["sort_by"] || "id",
      sort_order: params["sort_order"] || "asc"
    }

    socket =
      socket
      |> assign(:filters, options)
      |> stream(:colleges, Colleges.get_program_data(options, socket.assigns.program.id))

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", filters, socket) do
    filters |> dbg()

    filters =
      filters
      |> Map.delete("_target")
      |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

    updated_filters = Map.merge(socket.assigns.filters, filters)

    {:noreply,
     socket
     |> push_patch(to: ~p"/programs/#{socket.assigns.program}?#{build_query(updated_filters)}")}
  end

  def build_query(filters) do
    filters
    |> Enum.filter(fn
      {:sort_by, "id"} -> false
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
end

#   @impl true
#   def handle_params(params, _url, socket) do
#     options = %{
#       name: params["name"],
#       sort_by: params["sort_by"] || "id",
#       sort_order: params["sort_order"] || "asc"
#     }

#     socket =
#       socket
#       |> assign(:filters, options)
#       |> stream(:programs, Colleges.get_programs_with_filter(options), reset: true)

#     {:noreply, socket}
#   end

# end
