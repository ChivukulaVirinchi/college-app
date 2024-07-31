defmodule CounsellingWeb.CollegeLive.Index do
  use CounsellingWeb, :live_view

  alias Counselling.Colleges
  alias Counselling.Colleges.College

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, filters: %{name: "", location: ""})
    {:ok, stream(socket, :colleges, Colleges.list_colleges())}
  end

  @impl true
  # def handle_params(params, _url, socket) do
  #   {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  # end

  def handle_params(params, _uri, socket) do
    params |> dbg()
    # sort_by = (params["sort_by"] || "id") |> String.to_atom()
    # sort_order = (params["sort_order"] || "asc") |> String.to_atom()

    # page = (params["page"] || "1") |> String.to_integer()
    # per_page = (params["per_page"] || "5") |> String.to_integer()
    # options = %{sort_by: sort_by, sort_order: sort_order, page: page, per_page: per_page}
    options = %{
      name: params["name"],
      location: params["location"]
      # class: params["class"]
    }

    socket =
      socket
      |> assign(options: options)
      |> stream(:colleges, Colleges.get_colleges_with_filter(options), reset: true)

    {:noreply, socket}
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit College")
  #   |> assign(:college, Colleges.get_college!(id))
  # end

  # defp apply_action(socket, :new, _params) do
  #   socket
  #   |> assign(:page_title, "New College")
  #   |> assign(:college, %College{})
  # end

  # defp apply_action(socket, :index, _params) do
  #   socket
  #   |> assign(:page_title, "Listing Colleges")
  #   |> assign(:college, nil)
  # end

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

  # def handle_event("update-filter", params, socket) do
  #   params = Map.delete(params, "_target")
  #   {:noreply, push_patch(socket, to: ~p"/colleges?#{params}")}
  # end
  def handle_event("filter", filters, socket) do
    # params = Map.put(params, "institutes", filters["institutes"])
    filters =
      filters
      |> Map.delete("_target")
      |> Enum.reject(fn {_key, value} -> value == "" end)
      |> Map.new()

    updated_filters = Map.merge(socket.assigns.filters, filters)

    updated_filters |> dbg()

    {:noreply,
     socket
     |> assign(filters: updated_filters)
     |> push_patch(to: ~p"/colleges?#{build_query(updated_filters)}")}
  end

  def build_query(filters) do
    filters
    |> Enum.filter(fn {_, v} -> v && v != "" end)
  end
end
