defmodule CounsellingWeb.CollegeLive.Index do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges
  # alias CounsellingWeb.CollegeComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        filters: %{
          "name" => "",
          "location" => "",
          "class" => [],
          "advanced_rank" => "",
          selected_programs: []
        },
        page_title: "Colleges"
      )

    # |> assign(:programs, Colleges.list_programs())

    {:ok,
     stream(socket, :colleges, Colleges.get_colleges_with_filter(socket.assigns.filters),
       reset: true
     )}
  end

  @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  def handle_params(params, _uri, socket) do
    # sort_by = (params["sort_by"] || "id") |> String.to_atom()
    # sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    # page = (params["page"] || "1") |> String.to_integer()
    # per_page = (params["per_page"] || "5") |> String.to_integer()
    options = %{
      name: params["name"],
      location: params["location"],
      class: params["class"],
      advanced_rank: params["advanced_rank"],
      programs: params["programs"]
    }

    socket =
      socket
      |> stream(:colleges, Colleges.get_colleges_with_filter(options), reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_info({CounsellingWeb.CollegeLive.FormComponent, {:saved, college}}, socket) do
    {:noreply, stream_insert(socket, :colleges, college)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    college = Colleges.get_college!(id)
    {:ok, _} = Colleges.delete_college(college)

    {:noreply, stream_delete(socket, :colleges, college)}
  end

  # def handle_event("create-college", _, socket) do
  #   # AnthropicApi.call_claude()
  #   for x <- AnthropicApi.call_claude().body["content"] do
  #     case Colleges.create_college(x["input"]) do
  #       {:ok, college} ->
  #         IO.puts("College created: #{college.name}")

  #       {:error, changeset} ->
  #         IO.puts("Error creating college: #{inspect(changeset.errors)}")
  #     end
  #   end

  #   {:noreply, socket}
  # end

  def handle_event("filter", filters, socket) do
    # params = Map.put(params, "institutes", filters["institutes"])
    filters =
      filters
      |> Map.delete("_target")
      |> update_checkbox_filters("class")
      # |> Enum.reject(fn {_key, value} -> value == "" end)
      |> Map.new()

    updated_filters = Map.merge(socket.assigns.filters, filters)

    {:noreply,
     socket
     |> assign(filters: updated_filters)
     |> assign(advanced_rank: filters["advanced_rank"])
     |> push_patch(to: ~p"/colleges?#{build_query(updated_filters)}")}
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

  def program_names() do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
