defmodule CounsellingWeb.CollegeLive.Index do
  use CounsellingWeb, :live_view

  alias Counselling.Colleges
  alias Counselling.Colleges.College

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :colleges, Colleges.list_colleges())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit College")
    |> assign(:college, Colleges.get_college!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New College")
    |> assign(:college, %College{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Colleges")
    |> assign(:college, nil)
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

  def handle_event("create-college", _, socket) do
    # AnthropicApi.call_claude()
    for x <- AnthropicApi.call_claude().body["content"] do
      case Colleges.create_college(x["input"]) do
        {:ok, college} ->
          IO.puts("College created: #{college.name}")

        {:error, changeset} ->
          IO.puts("Error creating college: #{inspect(changeset.errors)}")
      end
    end

    {:noreply, socket}
  end
end
