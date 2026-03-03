defmodule CounsellingWeb.ProgramLive.Show do
  use CounsellingWeb, :live_view
  import Ecto.Query
  use LiveTable.LiveResource
  alias Counselling.Programs

  @latest_year Josaa.latest_year()

  @impl true
  def mount(params, _session, socket) do
    [id_str | _] = String.split(params["program"], "-")
    id = String.to_integer(id_str)
    program = Programs.get_program!(id)

    socket =
      socket
      |> assign(:data_provider, {Programs, :list_colleges, [id]})
      |> assign(:program, program)
      |> assign(:program_id, id)
      |> assign(:seat_type, :open)
      |> assign(:latest_year, @latest_year)
      |> assign(:college_count, Programs.get_college_count(id))
      |> assign(:page_title, "#{program.name} - Colleges & Cutoffs")
      |> assign(:canonical_url, url(~p"/programs/#{program}"))
      |> assign(
        :meta_description,
        "#{program.name} program across engineering colleges. Compare cutoffs, NIRF rankings and admission chances at IITs, NITs, IIITs."
      )

    {:ok, socket}
  end

  def handle_event("change_category", %{"seat_type" => seat_type}, socket) do
    seat_type_atom = String.to_existing_atom(seat_type)
    id = socket.assigns.program_id
    data_provider = {Programs, :list_colleges, [id, seat_type_atom]}

    socket = assign(socket, :data_provider, data_provider)

    options = socket.assigns.options

    {resources, updated_options} =
      case stream_resources(fields(), options, data_provider) do
        {resources, overflow} ->
          has_next_page = length(overflow) > 0
          {resources, put_in(options["pagination"][:has_next_page], has_next_page)}

        resources when is_list(resources) ->
          {resources, options}
      end

    socket =
      socket
      |> assign(:options, updated_options)
      |> assign(:seat_type, seat_type_atom)
      |> stream(:resources, resources,
        dom_id: fn _ -> "resource-#{Ecto.UUID.generate()}" end,
        reset: true
      )

    {:noreply, socket}
  end

  def fields do
    []
  end

  def filters do
    [
      iit:
        Boolean.new(
          :class,
          "iit",
          %{
            label: "IIT",
            condition: dynamic([_, _, c], c.class == :IIT)
          }
        ),
      nit:
        Boolean.new(
          :class,
          "nit",
          %{
            label: "NIT",
            condition: dynamic([_, _, c], c.class == :NIT)
          }
        ),
      iiit:
        Boolean.new(
          :class,
          "iiit",
          %{
            label: "IIIT",
            condition: dynamic([_, _, c], c.class == :IIIT)
          }
        ),
      gfti:
        Boolean.new(
          :class,
          "gfti",
          %{
            label: "GFTI",
            condition: dynamic([_, _, c], c.class == :GFTI)
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

  def table_options do
    %{
      mode: :card,
      card_component: &CounsellingWeb.CollegeComponent2.college_component2/1,
      custom_header: {CounsellingWeb.CollegeLive.CustomHeader, :custom_header},
      empty_state: fn _assigns -> CounsellingWeb.EmptyState.empty_state(%{context: :program_colleges}) end
    }
  end

  def rank_filter(query, %{"value" => ""}) do
    query
  end

  def rank_filter(query, %{"value" => rank}) do
    number = String.to_integer(rank)

    query
    |> where(
      [_, _, c, _, rc],
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

  def sort_query(query, %{"sort_by" => "Established Year"}) do
    query |> exclude(:order_by) |> order_by([_, _, c], c.established_year)
  end

  def sort_query(query, %{"sort_by" => "Name (A-Z)"}) do
    query |> exclude(:order_by) |> order_by([_, _, c], c.name)
  end

  def sort_query(query, %{"sort_by" => "Name (Z-A)"}) do
    query |> exclude(:order_by) |> order_by([_, _, c], desc: c.name)
  end

  def sort_query(query, _params) do
    query
  end

  @seat_type_labels %{
    open: "OPEN",
    obc_ncl: "OBC-NCL",
    sc: "SC",
    st: "ST",
    ews: "EWS",
    open_pwd: "OPEN (PwD)",
    obc_ncl_pwd: "OBC-NCL (PwD)",
    sc_pwd: "SC (PwD)",
    st_pwd: "ST (PwD)",
    ews_pwd: "EWS (PwD)"
  }

  def seat_type_label(seat_type), do: Map.get(@seat_type_labels, seat_type, "OPEN")
end
