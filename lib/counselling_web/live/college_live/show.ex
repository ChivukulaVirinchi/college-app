defmodule CounsellingWeb.CollegeLive.Show do
  use CounsellingWeb, :live_view

  alias Counselling.Colleges

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    [id_str | _] = String.split(slug, "-")
    id = String.to_integer(id_str)

    {:noreply,
     socket
     |> assign(:advanced_rank, 2000)
     |> assign(:rank, 38000)
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:college, Colleges.get_college_program_rank_data_by_id(id))}
  end

  def get_rank_color(opening_rank, closing_rank, rank) do
    cond do
      rank >= closing_rank ->
        "text-red-600 bg-red-100"

      rank <= opening_rank ->
        "text-green-600 bg-green-100"

      true ->
        "text-yellow-600 bg-yellow-100"
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
