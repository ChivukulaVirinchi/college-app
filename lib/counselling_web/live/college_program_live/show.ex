defmodule CounsellingWeb.CollegeProgramLive.Show do
  use CounsellingWeb, :live_view
  use LiveTable.LiveResource

  alias Counselling.{Ranks, Colleges, Programs}
  alias CounsellingWeb.RankComponent
  import CounsellingWeb.CollegeLive.Show, only: [nirf_helper: 1, nirf_band?: 1]

  @latest_year Josaa.latest_year()

  @impl true
  def mount(params, _session, socket) do
    [college_id_str | _] = String.split(params["college"], "-")
    [program_id_str | _] = String.split(params["program"], "-")

    college_id = String.to_integer(college_id_str)
    program_id = String.to_integer(program_id_str)

    college = Colleges.get_college!(college_id)
    program = Programs.get_program!(program_id)

    # All cutoffs for the chart (all years, all seat types)
    all_cutoffs = Ranks.get_rank_cutoffs(college_id, program_id)

    socket =
      socket
      |> assign(:data_provider, {Ranks, :get_college_program_cutoffs, [college_id, program_id]})
      |> assign(:college, college)
      |> assign(:program, program)
      |> assign(:page_title, "#{program.name} at #{college.name} - Cutoffs & Rankings")
      |> assign(:canonical_url, url(~p"/colleges/#{college}/programs/#{program}"))
      |> assign(
        :meta_description,
        "#{program.name} at #{college.name} - JEE cutoffs, historical trends, and admission chances."
      )
      |> assign(:all_cutoffs, all_cutoffs)
      |> assign(:latest_year, @latest_year)

    {:ok, socket}
  end

  def fields do
    [
      quota: %{
        label: "Quota",
        sortable: false,
        renderer: &process_quota/1
      },
      gender: %{
        label: "Gender",
        sortable: false,
        renderer: &process_gender/1
      },
      seat_type: %{
        label: "Category",
        sortable: false,
        renderer: &process_seat_type/1
      },
      opening_rank: %{
        label: "Opening Rank",
        sortable: false,
        assoc: {:rank_cutoff, :opening_rank},
        renderer: &RankComponent.rank_badge/1
      },
      closing_rank: %{
        label: "Closing Rank",
        sortable: false,
        assoc: {:rank_cutoff, :closing_rank},
        renderer: &RankComponent.rank_badge/1
      }
    ]
  end

  def table_options do
    %{
      empty_state: fn _assigns -> CounsellingWeb.EmptyState.empty_state(%{context: :cutoffs}) end
    }
  end

  def filters do
    [
      gender_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Gender Neutral",
          condition: dynamic([rank_cutoff: rc], rc.gender == :gender_neutral),
          default: true
        }),
      female_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Female",
          condition: dynamic([rank_cutoff: rc], rc.gender == :female)
        }),
      seat_type_select:
        Select.new({:rank_cutoff, :seat_type}, "seat_type_select", %{
          label: "Category",
          mode: :single,
          allow_clear: false,
          options: [
            %{label: "OPEN", value: :open},
            %{label: "OBC-NCL", value: :obc_ncl},
            %{label: "SC", value: :sc},
            %{label: "ST", value: :st},
            %{label: "EWS", value: :ews},
            %{label: "OPEN (PwD)", value: :open_pwd},
            %{label: "OBC-NCL (PwD)", value: :obc_ncl_pwd},
            %{label: "SC (PwD)", value: :sc_pwd},
            %{label: "ST (PwD)", value: :st_pwd},
            %{label: "EWS (PwD)", value: :ews_pwd}
          ],
          selected: [],
          placeholder: "Select category..."
        }),
      hs:
        Boolean.new(:quota, "quota-filter", %{
          label: "Home State",
          condition: dynamic([rank_cutoff: rc], rc.quota == :home_state)
        }),
      all_india:
        Boolean.new(:quota, "quota-filter", %{
          label: "All India",
          condition: dynamic([rank_cutoff: rc], rc.quota == :all_india)
        }),
      os:
        Boolean.new(:quota, "quota-filter", %{
          label: "Other State",
          condition: dynamic([rank_cutoff: rc], rc.quota == :other_state)
        })
    ]
  end

  @quota_filter_keys [:hs, :all_india, :os]

  # IITs only have all_india — no quota filter needed
  def filters_for(:IIT), do: Keyword.drop(filters(), @quota_filter_keys)
  # NITs have home_state + other_state — drop redundant all_india
  def filters_for(:NIT), do: Keyword.drop(filters(), [:all_india])
  # IIITs/GFTIs only have all_india — no quota filter needed
  def filters_for(_class), do: Keyword.drop(filters(), @quota_filter_keys)

  def process_quota(:all_india), do: "All India"
  def process_quota(:home_state), do: "Home State"
  def process_quota(:other_state), do: "Other State"
  def process_quota(:go), do: "Goa"
  def process_quota(:jk), do: "J & K"
  def process_quota(:la), do: "Ladakh"

  defp process_gender(:gender_neutral), do: "Gender Neutral"
  defp process_gender(:female), do: "Female Only"
  defp process_gender(_), do: "Gender Neutral"

  defp process_seat_type(:open), do: "OPEN"
  defp process_seat_type(:obc_ncl), do: "OBC-NCL"
  defp process_seat_type(:sc), do: "SC"
  defp process_seat_type(:st), do: "ST"
  defp process_seat_type(:ews), do: "EWS"
  defp process_seat_type(:open_pwd), do: "OPEN (PwD)"
  defp process_seat_type(:obc_ncl_pwd), do: "OBC-NCL (PwD)"
  defp process_seat_type(:sc_pwd), do: "SC (PwD)"
  defp process_seat_type(:st_pwd), do: "ST (PwD)"
  defp process_seat_type(:ews_pwd), do: "EWS (PwD)"
  defp process_seat_type(other), do: other |> to_string() |> String.upcase()
end
