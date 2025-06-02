defmodule CounsellingWeb.PageController do
  use CounsellingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
