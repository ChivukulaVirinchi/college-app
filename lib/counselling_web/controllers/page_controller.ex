defmodule CounsellingWeb.PageController do
  use CounsellingWeb, :controller
  alias Counselling.{Colleges, Programs}

  def home(conn, _params) do
    render(conn, :home)
  end

  def sitemap(conn, _params) do
    colleges = Colleges.list_all_colleges_sitemap()
    programs = Programs.list_all_programs_sitemap()

    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url><loc>https://josaa.gurujada.com/</loc><priority>1.0</priority></url>
      <url><loc>https://josaa.gurujada.com/colleges</loc><priority>0.9</priority></url>
      <url><loc>https://josaa.gurujada.com/programs</loc><priority>0.9</priority></url>
    #{Enum.map_join(colleges, "", fn college -> "<url><loc>https://josaa.gurujada.com/colleges/#{college.id}-#{college.slug}</loc><priority>0.8</priority></url>" end)}
    #{Enum.map_join(programs, "", fn program -> "<url><loc>https://josaa.gurujada.com/programs/#{program.id}-#{program.slug}</loc><priority>0.7</priority></url>" end)}
    </urlset>
    """

    conn
    |> put_resp_content_type("application/xml")
    |> text(xml)
  end
end
