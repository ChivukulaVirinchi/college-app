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
      btech:
        Boolean.new(:btech, "degree_type", %{
          label: "B.Tech",
          condition: dynamic([p], p.degree_type == "Bachelor of Technology")
        }),
      bmtech:
        Boolean.new(:bmtech, "degree_type", %{
          label: "B.Tech + M.Tech",
          condition:
            dynamic([p], p.degree_type == "Bachelor and Master of Technology (Dual Degree)")
        }),
      bsc:
        Boolean.new(:bsc, "degree_type", %{
          label: "B.Sc",
          condition: dynamic([p], p.degree_type == "Bachelor of Science")
        }),
      bscmsc:
        Boolean.new(:bscmsc, "degree_type", %{
          label: "B.Sc + M.Sc",
          condition:
            dynamic(
              [p],
              p.degree_type == "Bachelor of Science and Master of Science (Dual Degree)"
            )
        }),
      barch:
        Boolean.new(:barch, "degree_type", %{
          label: "B.Arch",
          condition: dynamic([p], p.degree_type == "Bachelor of Architecture")
        }),
      btechmba:
        Boolean.new(:btechmba, "degree_type", %{
          label: "B.Tech + MBA (Integrated)",
          condition: dynamic([p], p.degree_type == "Integrated B. Tech. and MBA")
        }),
      btechmtech:
        Boolean.new(:btechmtech, "degree_type", %{
          label: "B.Tech + M.Tech (Integrated)",
          condition: dynamic([p], p.degree_type == "Integrated B. Tech. and M. Tech.")
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

  # defp process_degree_type("Bachelor and Master of Technology (Dual Degree)"),
  #   do: "B.Tech + M.Tech"

  # defp process_degree_type("Bachelor of Science"), do: "B.Sc"

  # defp process_degree_type("Bachelor of Science and Master of Science (Dual Degree)"),
  #   do: "B.Sc + M.Sc"

  # defp process_degree_type("Bachelor of Architecture"), do: "B.Arch"
  # defp process_degree_type("Integrated B. Tech. and MBA"), do: "B.Tech + MBA"
  # defp process_degree_type("Integrated B. Tech. and M. Tech."), do: "B.Tech + M.Tech"

  def table_options do
    %{
      mode: :card,
      custom_header: {CustomHeader, :custom_header},
      card_component: &CounsellingWeb.ProgramComponent.program_component/1
    }
  end
end
