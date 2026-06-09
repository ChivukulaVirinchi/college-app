defmodule CounsellingWeb.PageController do
  use CounsellingWeb, :controller
  alias Counselling.{Colleges, Programs}
  alias CounsellingWeb.SEO

  def home(conn, _params) do
    base_url = url(conn, ~p"/")
    page_title = "JOSAA Counselling Helper"
    meta_description = SEO.default_description()

    render(conn, :home,
      latest_year: Josaa.latest_year(),
      college_count: Colleges.count_colleges(),
      program_count: Programs.count_programs(),
      page_title: page_title,
      meta_description: meta_description,
      canonical_url: base_url,
      json_ld: [
        SEO.website_json_ld(base_url),
        SEO.organization_json_ld(base_url),
        SEO.web_page_json_ld(page_title, meta_description, base_url)
      ]
    )
  end

  def guide(conn, _params) do
    path = conn.request_path
    page = guide_page(path)
    base_url = url(conn, ~p"/")
    canonical_url = URI.merge(base_url, path) |> URI.to_string()

    render(conn, :guide,
      page: page,
      latest_year: Josaa.latest_year(),
      canonical_url: canonical_url,
      page_title: page.title,
      meta_description: page.description,
      json_ld: [
        SEO.web_page_json_ld(page.title, page.description, canonical_url),
        SEO.breadcrumb_json_ld([
          {"Home", base_url},
          {page.h1, canonical_url}
        ]),
        SEO.faq_json_ld(page.faq)
      ]
    )
  end

  def methodology(conn, _params) do
    base_url = url(conn, ~p"/")
    canonical_url = url(conn, ~p"/methodology")
    page_title = "Data Methodology - JOSAA Counselling Helper"

    meta_description =
      "How JOSAA Counselling Helper uses JoSAA cutoffs and NIRF rankings for college and program discovery."

    render(conn, :methodology,
      latest_year: Josaa.latest_year(),
      canonical_url: canonical_url,
      page_title: page_title,
      meta_description: meta_description,
      json_ld: [
        SEO.web_page_json_ld(page_title, meta_description, canonical_url),
        SEO.breadcrumb_json_ld([
          {"Home", base_url},
          {"Methodology", canonical_url}
        ])
      ]
    )
  end

  def sitemap(conn, _params) do
    colleges = Colleges.list_all_colleges_sitemap()
    programs = Programs.list_all_programs_sitemap()
    college_programs = Colleges.list_all_college_programs_sitemap()
    today = Date.utc_today() |> Date.to_iso8601()

    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      #{sitemap_url("https://josaa.gurujada.com/", today, "1.0")}
      #{sitemap_url("https://josaa.gurujada.com/methodology", today, "0.7")}
      #{sitemap_url("https://josaa.gurujada.com/colleges", today, "0.9")}
      #{sitemap_url("https://josaa.gurujada.com/programs", today, "0.9")}
      #{sitemap_url("https://josaa.gurujada.com/josaa-college-predictor", today, "0.9")}
      #{sitemap_url("https://josaa.gurujada.com/jee-main-college-predictor", today, "0.9")}
      #{sitemap_url("https://josaa.gurujada.com/iit-cutoff-2026", today, "0.8")}
      #{sitemap_url("https://josaa.gurujada.com/nit-cutoff-2026", today, "0.8")}
      #{sitemap_url("https://josaa.gurujada.com/iiit-cutoff-2026", today, "0.8")}
      #{sitemap_url("https://josaa.gurujada.com/josaa-opening-closing-rank", today, "0.8")}
    #{Enum.map_join(colleges, "", fn college -> sitemap_url("https://josaa.gurujada.com/colleges/#{college.id}-#{college.slug}", sitemap_date(college.updated_at), "0.8") end)}
    #{Enum.map_join(programs, "", fn program -> sitemap_url("https://josaa.gurujada.com/programs/#{program.id}-#{program.slug}", sitemap_date(program.updated_at), "0.7") end)}
    #{Enum.map_join(college_programs, "", fn cp -> sitemap_url("https://josaa.gurujada.com/colleges/#{cp.college_id}-#{cp.college_slug}/programs/#{cp.program_id}-#{cp.program_slug}", sitemap_date(cp.updated_at), "0.8") end)}
    </urlset>
    """

    conn
    |> put_resp_content_type("application/xml")
    |> text(xml)
  end

  defp guide_page("/josaa-college-predictor") do
    %{
      title: "JoSAA College Predictor 2026 - IIT, NIT, IIIT Cutoff Finder",
      h1: "JoSAA College Predictor",
      kicker: "Rank-based college discovery",
      description:
        "Use JoSAA cutoff data to find IIT, NIT, IIIT and GFTI options by JEE rank, category, quota and gender.",
      body:
        "Enter your JEE rank on the colleges or programs pages to filter options using the latest available JoSAA opening and closing ranks. The predictor is useful for shortlisting realistic choices before filling JoSAA preference order.",
      primary_path: ~p"/colleges",
      primary_label: "Explore Colleges",
      secondary_path: ~p"/programs",
      secondary_label: "Browse Programs",
      bullets: [
        "Filter by OPEN, OBC-NCL, SC, ST, EWS and PwD categories.",
        "Compare IIT, NIT, IIIT and GFTI options with NIRF rankings.",
        "Open any college-program page to inspect historical cutoff trends."
      ],
      faq: [
        {"Is this an official JoSAA predictor?",
         "No. It is an independent counselling helper based on JoSAA cutoff data and NIRF ranking data."},
        {"Which rank should I enter?",
         "Use the applicable JEE Main or JEE Advanced rank for the institute and program type you are checking."}
      ]
    }
  end

  defp guide_page("/jee-main-college-predictor") do
    %{
      title: "JEE Main College Predictor 2026 - NIT, IIIT and GFTI Options",
      h1: "JEE Main College Predictor",
      kicker: "NIT, IIIT and GFTI counselling",
      description:
        "Find NIT, IIIT and GFTI options for your JEE Main rank using JoSAA opening and closing rank data.",
      body:
        "JEE Main ranks are used for NITs, IIITs and GFTIs in JoSAA counselling. Use the rank filter, category filter and quota filter together to build a practical preference list.",
      primary_path: ~p"/colleges",
      primary_label: "Find Colleges",
      secondary_path: ~p"/programs",
      secondary_label: "Find Programs",
      bullets: [
        "Check Other State and Home State quota where applicable.",
        "Use closing rank as the last admitted rank for a seat type.",
        "Compare colleges before finalizing preference order."
      ],
      faq: [
        {"Does JEE Main apply to IITs?",
         "No. IIT admission through JoSAA uses JEE Advanced rank, while NITs, IIITs and GFTIs use JEE Main rank."},
        {"Can cutoff ranks change in 2026?",
         "Yes. Cutoffs vary every year based on choices, seats, category, quota and exam rank distribution."}
      ]
    }
  end

  defp guide_page("/iit-cutoff-2026"), do: cutoff_page("IIT", "IIT Cutoff 2026", "JEE Advanced")
  defp guide_page("/nit-cutoff-2026"), do: cutoff_page("NIT", "NIT Cutoff 2026", "JEE Main")
  defp guide_page("/iiit-cutoff-2026"), do: cutoff_page("IIIT", "IIIT Cutoff 2026", "JEE Main")

  defp guide_page("/josaa-opening-closing-rank") do
    %{
      title: "JoSAA Opening and Closing Rank Explained",
      h1: "JoSAA Opening and Closing Rank",
      kicker: "Cutoff basics",
      description:
        "Understand JoSAA opening rank, closing rank, category, quota and gender filters before using cutoff data.",
      body:
        "Opening rank is the earliest rank admitted for a program-category combination, while closing rank is the last rank admitted. Closing rank is usually the more useful number when estimating admission chances.",
      primary_path: ~p"/colleges",
      primary_label: "Check Cutoffs",
      secondary_path: ~p"/programs",
      secondary_label: "Browse Programs",
      bullets: [
        "Always match category, quota and gender before comparing ranks.",
        "A lower rank number means a stronger exam rank.",
        "Historical closing ranks are guidance, not a guarantee."
      ],
      faq: [
        {"Is closing rank a guarantee?",
         "No. It is historical data from previous allotment rounds and can change in the next counselling cycle."},
        {"Why do categories have different cutoffs?",
         "JoSAA publishes cutoffs separately by seat type, quota and gender because those seat pools are allotted separately."}
      ]
    }
  end

  defp cutoff_page(type, h1, exam) do
    type_downcase = String.downcase(type)

    %{
      title: "#{h1} - JoSAA Opening and Closing Ranks",
      h1: h1,
      kicker: "#{type} counselling data",
      description:
        "Check #{type} JoSAA cutoff trends, opening ranks and closing ranks by program, category and quota.",
      body:
        "#{type} cutoffs depend on #{exam} rank, branch demand, category, gender and available seats. Use the college and program pages to inspect current and historical JoSAA cutoff rows.",
      primary_path: ~p"/colleges",
      primary_label: "Browse #{type} Colleges",
      secondary_path: ~p"/programs",
      secondary_label: "Compare Programs",
      bullets: [
        "Filter institute type to #{type} on the colleges page.",
        "Open a program page to compare #{type_downcase} options by closing rank.",
        "Use NIRF ranking together with cutoffs instead of relying on rank alone."
      ],
      faq: [
        {"Which exam rank is used for #{type} cutoffs?",
         "#{type} JoSAA cutoffs are checked against #{exam} rank."},
        {"Are 2026 cutoffs final?",
         "Final 2026 cutoffs are known only after JoSAA publishes allotment data. Until then, previous years are useful for planning."}
      ]
    }
  end

  defp sitemap_url(loc, lastmod, priority) do
    """
    <url><loc>#{xml_escape(loc)}</loc><lastmod>#{lastmod}</lastmod><priority>#{priority}</priority></url>
    """
  end

  defp sitemap_date(nil), do: Date.utc_today() |> Date.to_iso8601()
  defp sitemap_date(%Date{} = date), do: Date.to_iso8601(date)

  defp sitemap_date(%NaiveDateTime{} = datetime),
    do: datetime |> NaiveDateTime.to_date() |> Date.to_iso8601()

  defp sitemap_date(%DateTime{} = datetime),
    do: datetime |> DateTime.to_date() |> Date.to_iso8601()

  defp xml_escape(value) do
    value
    |> to_string()
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end
end
