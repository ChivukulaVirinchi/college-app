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
     |> assign(:college, Colleges.get_college_program_rank_data_by_id(id))}
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
