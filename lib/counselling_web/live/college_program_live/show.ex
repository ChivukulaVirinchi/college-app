defmodule CounsellingWeb.CollegeProgramLive.Show do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  # def handle_params(%{"slug" => slug}, _, socket) do
  #   [college_id_str, program_id_str | _] = String.split(slug, "-")
  #   college_id = String.to_integer(college_id_str)
  #   program_id = String.to_integer(program_id_str)

  #   {:noreply,
  #    socket
  #    |> assign(:college, Colleges.get_college_data(college_id))
  #    |> assign(:program, Colleges.get_program_data(program_id))}
  # end
end
