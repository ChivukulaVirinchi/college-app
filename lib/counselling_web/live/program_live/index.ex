defmodule CounsellingWeb.ProgramLive.Index do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges

  def mount(_params, _session, socket) do
    socket |> stream(:programs, Colleges.list_programs())
    {:ok, socket}
  end
end
