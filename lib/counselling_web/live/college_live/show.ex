defmodule CounsellingWeb.CollegeLive.Show do
  use CounsellingWeb, :live_view

  alias Counselling.Colleges

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:college, Colleges.get_college!(id))}
  end

  defp page_title(:show), do: "Show College"
  defp page_title(:edit), do: "Edit College"
end
