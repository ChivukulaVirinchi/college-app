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
