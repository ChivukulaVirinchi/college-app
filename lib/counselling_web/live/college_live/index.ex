defmodule CounsellingWeb.CollegeLive.Index do
  use CounsellingWeb, :live_view
  alias Counselling.Colleges
  alias CounsellingWeb.CollegeLive.CustomHeader
  use LiveTable.LiveResource
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    college_count = Colleges.count_colleges()
    base_url = url(~p"/")
    canonical_url = url(~p"/colleges")
    page_title = "Engineering Colleges - JOSAA Helper"

    meta_description =
      "Browse #{college_count}+ engineering colleges (IITs, NITs, IIITs, GFTIs) with JEE rank-based filtering, cutoffs, and NIRF rankings. Find colleges you can get admission to."

    socket =
      socket
      |> assign(:page_title, page_title)
      |> assign(:canonical_url, canonical_url)
      |> assign(:data_provider, {Colleges, :list_colleges, []})
      |> assign(:college_count, college_count)
      |> assign(:meta_description, meta_description)
      |> assign(:json_ld, [
        CounsellingWeb.SEO.web_page_json_ld(page_title, meta_description, canonical_url),
        CounsellingWeb.SEO.breadcrumb_json_ld([
          {"Home", base_url},
          {"Colleges", canonical_url}
        ])
      ])

    {:ok, socket}
  end

  def fields do
    [
      id: %{label: "ID", sortable: true},
      name: %{label: "College Name", sortable: true, searchable: true},
      location: %{label: "Location", sortable: true, searchable: true}
    ]
  end

  def table_options do
    %{
      mode: :card,
      card_component: &CounsellingWeb.CollegeComponent.college_component/1,
      custom_header: {CustomHeader, :custom_header},
      empty_state: fn _assigns -> CounsellingWeb.EmptyState.empty_state(%{context: :colleges}) end
    }
  end

  def filters do
    [
      iit:
        Boolean.new(
          :class,
          "iit",
          %{
            label: "IIT",
            condition: dynamic([c], c.class == :IIT)
          }
        ),
      nit:
        Boolean.new(
          :class,
          "nit",
          %{
            label: "NIT",
            condition: dynamic([c], c.class == :NIT)
          }
        ),
      iiit:
        Boolean.new(
          :class,
          "iiit",
          %{
            label: "IIIT",
            condition: dynamic([c], c.class == :IIIT)
          }
        ),
      gfti:
        Boolean.new(
          :class,
          "gfti",
          %{
            label: "GFTI",
            condition: dynamic([c], c.class == :GFTI)
          }
        ),
      rank:
        Transformer.new("rank", %{
          query_transformer: &rank_filter/2
        }),
      sort_mode:
        Transformer.new("sort_mode", %{
          query_transformer: &sort_query/2
        }),
      limit_results:
        Transformer.new("limit_results", %{
          query_transformer: &limit_results/2
        })
    ]
  end

  def rank_filter(query, %{"value" => ""}) do
    query
  end

  def rank_filter(query, %{"value" => rank}) do
    number = String.to_integer(rank)

    query
    |> where(
      [c, _, rc],
      rc.closing_rank >= ^number or
        rc.closing_rank +
          fragment(
            """
              CASE ?
                WHEN 'IIT' THEN ? * 0.05 *
                  CASE WHEN ? <= 1000 THEN 0.8
                       WHEN ? <= 5000 THEN 1.0
                       WHEN ? <= 20000 THEN 1.2
                       ELSE 1.5 END
                WHEN 'NIT' THEN ? * 0.08 *
                  CASE WHEN ? <= 1000 THEN 0.8
                       WHEN ? <= 5000 THEN 1.0
                       WHEN ? <= 20000 THEN 1.2
                       ELSE 1.5 END
                WHEN 'IIIT' THEN ? * 0.12 *
                  CASE WHEN ? <= 1000 THEN 0.8
                       WHEN ? <= 5000 THEN 1.0
                       WHEN ? <= 20000 THEN 1.2
                       ELSE 1.5 END
                ELSE ? * 0.15 *
                  CASE WHEN ? <= 1000 THEN 0.8
                       WHEN ? <= 5000 THEN 1.0
                       WHEN ? <= 20000 THEN 1.2
                       ELSE 1.5 END
              END
            """,
            c.class,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank,
            rc.closing_rank
          ) >= ^number
    )
  end

  def limit_results(query, %{"nirf" => "Top 10"}) do
    query |> where([_, _, _, nr], nr.nirf_rank <= 10)
  end

  def limit_results(query, %{"nirf" => "Top 25"}) do
    query |> where([_, _, _, nr], nr.nirf_rank <= 25)
  end

  def limit_results(query, %{"nirf" => "Top 50"}) do
    query |> where([_, _, _, nr], nr.nirf_rank <= 50)
  end

  def limit_results(query, %{"nirf" => "Top 100"}) do
    query |> where([_, _, _, nr], nr.nirf_rank <= 100)
  end

  def limit_results(query, %{"nirf" => "All Rankings"}) do
    query
  end

  def sort_query(query, %{"sort_by" => "NIRF Ranking"}) do
    query |> exclude(:order_by) |> order_by([_, _, _, nr], nr.nirf_rank)
  end

  def sort_query(query, %{"sort_by" => "Name (A-Z)"}) do
    query |> exclude(:order_by) |> order_by([c], c.name)
  end

  def sort_query(query, %{"sort_by" => "Established Year"}) do
    query |> exclude(:order_by) |> order_by([c], c.established_year)
  end

  def sort_query(query, %{"sort_by" => "Name (Z-A)"}) do
    query |> exclude(:order_by) |> order_by([c], desc: c.name)
  end

  def sort_query(query, _params) do
    query
  end
end
