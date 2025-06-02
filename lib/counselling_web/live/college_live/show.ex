defmodule CounsellingWeb.CollegeLive.Show do
  use CounsellingWeb, :live_view
  use LiveTable.LiveResource

  alias Counselling.Colleges

  @impl true
  def mount(params, _session, socket) do
    [id_str | _] = String.split(params["college"], "-")
    id = String.to_integer(id_str)
    college = Colleges.get_college!(id)

    socket =
      socket
      |> assign(:data_provider, {Colleges, :get_college_programs, [id]})
      |> assign(:page_title, college.name)
      |> assign(:college, college)
      |> assign(:similar_colleges, Colleges.get_similar_colleges(id))

    {:ok, socket}
  end

  def fields do
    [
      program: %{
        label: "Name",
        sortable: true,
        assoc: {:program, :name},
        renderer: fn value, record -> college_link(value, record) end,
        searchable: true
      },
      opening_rank: %{
        label: "Opening Rank",
        sortable: true,
        assoc: {:rank_cutoff, :opening_rank},
        renderer: &CounsellingWeb.RankComponent.rank_badge/1
      },
      closing_rank: %{
        label: "Closing Rank",
        sortable: true,
        assoc: {:rank_cutoff, :closing_rank},
        renderer: &CounsellingWeb.RankComponent.rank_badge/1
      },
      category: %{label: "Category", sortable: false, renderer: &process_category/1},
      quota: %{
        label: "Quota",
        sortable: false,
        assoc: {:rank_cutoff, :quota},
        renderer: &process_quota/1
      },
      degree_type: %{
        label: "Degree Type",
        sortable: false,
        assoc: {:program, :degree_type}
        # renderer: &process_degree_type/1
      }
    ]
  end

  def filters do
    [
      gender_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Gender Neutral",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.category == :gender_neutral)
        }),
      female_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Female",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.category == :female)
        }),
      hs:
        Boolean.new(:quota, "quota-filter", %{
          label: "Home State",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.quota == :home_state)
        }),
      all_india:
        Boolean.new(:quota, "quota-filter", %{
          label: "All India",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.quota == :all_india)
        }),
      os:
        Boolean.new(:quota, "quota-filter", %{
          label: "Other State",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.quota == :other_state)
        })
    ]
  end

  defp college_link(program, record) do
    assigns = %{
      program: program,
      record: record
    }

    ~H"""
    <.link class="hover:text-blue-400" navigate={~p"/colleges/#{@record.college}/programs/#{@program}"}>
      {@program.name}
    </.link>
    """
  end

  # defp process_degree_type("Bachelor of Technology"), do: "B.Tech"

  # defp process_degree_type("Bachelor and Master of Technology (Dual Degree)"),
  #   do: "B.Tech + M.Tech"

  # defp process_degree_type("Bachelor of Science"), do: "B.Sc"

  # defp process_degree_type("Bachelor of Science and Master of Science (Dual Degree)"),
  #   do: "B.Sc + M.Sc"

  # defp process_degree_type("Bachelor of Architecture"), do: "B.Arch"
  # defp process_degree_type("Integrated B. Tech. and MBA"), do: "B.Tech + MBA"
  # defp process_degree_type("Integrated B. Tech. and M. Tech."), do: "B.Tech + M.Tech"

  def table_options do
    %{}
  end

  defp process_quota(:all_india), do: "AI"
  defp process_quota(:home_state), do: "HS"
  defp process_quota(:other_state), do: "OS"

  defp process_category(:gender_neutral), do: "Gender Neutral"
  defp process_category(:female), do: "Female Only"
  defp process_category(_), do: "Gender Neutral"
end
