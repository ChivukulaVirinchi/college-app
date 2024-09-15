defmodule CounsellingWeb.CollegeLive.Index do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges
  import CounsellingWeb.CollegeComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        filters: %{
          "name" => "",
          "location" => "",
          "class" => [],
          selected_programs: %{}
        },
        page_title: "Colleges"
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    params |> dbg()

    options = %{
      name: params["name"],
      location: params["location"],
      class: params["class"],
      advanced_rank: params["advanced_rank"],
      mains_rank: params["mains_rank"],
      selected_programs: params["selected_programs"] || []
    }

    socket =
      socket
      |> stream(:colleges, Colleges.get_colleges_with_filter(options), reset: true)
      |> assign(form: to_form(socket.assigns.filters.selected_programs))
      |> assign(programs: Colleges.program_test(""))

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

  # def handle_event(
  #       "live_select_change",
  #       params,
  #       socket
  #     ) do
  #   {:noreply, assign(socket, :programs, Colleges.program_test(params["text"]))}
  # end

  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    send_update(LiveSelect.Component, id: live_select_id, form: Colleges.program_test(text))

    {:noreply, socket}
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
    filters =
      filters
      |> Map.delete("_target")
      |> update_checkbox_filters("class")
      |> update_checkbox_filters("selected_programs")
      |> Map.new()

    updated_filters = Map.merge(socket.assigns.filters, filters)

    {:noreply,
     socket
     |> assign(filters: updated_filters)
     |> assign(advanced_rank: filters[:advanced_rank])
     |> assign(mains_rank: filters[:mains_rank])
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
end
