defmodule CounsellingWeb.ProgramLive.Index do
  alias CounsellingWeb.ProgramLive.CustomHeader
  use CounsellingWeb, :live_view
  use LiveTable.LiveResource

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, data_provider: {Counselling.Programs, :list_programs, []})}
  end

  def fields do
    [
      id: %{label: "ID", sortable: false},
      name: %{label: "Name", sortable: false, searchable: true},
      duration: %{label: "Duration (Years)", sortable: true},
      degree_type: %{label: "Degree Type", sortable: true}
    ]
  end

  def filters do
    [
      limit_results:
        Transformer.new("limit_results", %{
          query_transformer: &degree_type/2
        }),
      rank:
        Transformer.new("rank", %{
          query_transformer: &rank_filter/2
        }),
      four_years:
        Boolean.new(:duration, "duration", %{
          label: "4 Years",
          condition: dynamic([p], p.duration == 4)
        }),
      five_years:
        Boolean.new(:duration, "duration", %{
          label: "5 Years",
          condition: dynamic([p], p.duration == 5)
        })
    ]
  end

  def rank_filter(query, %{"value" => ""}) do
    query
  end

  def rank_filter(query, %{"value" => rank}) do
    number = String.to_integer(rank)

    from(p in query,
      join: cp in Counselling.CollegePrograms.CollegeProgram,
      on: p.id == cp.program_id,
      join: rc in Counselling.Ranks.RankCutoff,
      on: rc.college_program_id == cp.id,
      join: c in Counselling.Colleges.College,
      on: c.id == cp.college_id,
      where:
        rc.year == 2024 and rc.category == :gender_neutral and
          rc.quota in [:all_india, :other_state] and
          (rc.closing_rank >= ^number or
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
               ) >= ^number),
      distinct: p.id
    )
  end

  def degree_type(query, %{"degree_type" => "All Degrees"}) do
    query
  end

  def degree_type(query, %{"degree_type" => value}) do
    query |> where([p], p.degree_type == ^value)
  end

  def degree_type(query, _params) do
    query
  end

  def table_options do
    %{
      mode: :card,
      custom_header: {CustomHeader, :custom_header},
      card_component: &CounsellingWeb.ProgramComponent.program_component/1
    }
  end
end
