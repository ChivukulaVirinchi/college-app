defmodule CounsellingWeb.ProgramLive.Index do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :programs, Colleges.list_programs())}
  end
end
