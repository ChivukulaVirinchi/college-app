defmodule CounsellingWeb.CollegeProgramLive.Show do
  use CounsellingWeb, :live_view
  alias Counselling.{Ranks, Colleges, Programs}
  alias CounsellingWeb.RankComponent
  import CounsellingWeb.CollegeLive.Show, only: [nirf_helper: 1]

  @latest_year Josaa.latest_year()

  @impl true
  def mount(params, _session, socket) do
    [college_id_str | _] = String.split(params["college"], "-")
    [program_id_str | _] = String.split(params["program"], "-")

    college_id = String.to_integer(college_id_str)
    program_id = String.to_integer(program_id_str)

    college = Colleges.get_college!(college_id)
    program = Programs.get_program!(program_id)

    rank_cutoffs = Ranks.get_rank_cutoffs(college_id, program_id)
    chart_data = format_chart_data(rank_cutoffs)

    socket =
      socket
      |> assign(:college, college)
      |> assign(:program, program)
      |> assign(:page_title, "#{program.name} at #{college.name} - Cutoffs & Rankings")
      |> assign(
        :meta_description,
        "#{program.name} at #{college.name} - JEE cutoffs, historical trends, and admission chances. View opening and closing ranks."
      )
      |> assign(:rank_cutoffs, rank_cutoffs)
      |> assign(:chart_data, chart_data)
      |> assign(:latest_year, @latest_year)

    {:ok, socket}
  end

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
  defp process_seat_type(other), do: other |> to_string() |> String.upcase()

  defp format_chart_data(rank_cutoffs) do
    # Filter to OPEN seat_type only for chart
    open_cutoffs = Enum.filter(rank_cutoffs, fn c -> c.seat_type == :open end)

    grouped =
      Enum.group_by(open_cutoffs, fn cutoff ->
        {cutoff.quota, cutoff.gender}
      end)

    %{
      all_india: %{
        gender_neutral: format_trend_line(grouped[{:all_india, :gender_neutral}] || []),
        female: format_trend_line(grouped[{:all_india, :female}] || [])
      },
      home_state: %{
        gender_neutral: format_trend_line(grouped[{:home_state, :gender_neutral}] || []),
        female: format_trend_line(grouped[{:home_state, :female}] || [])
      },
      other_state: %{
        gender_neutral: format_trend_line(grouped[{:other_state, :gender_neutral}] || []),
        female: format_trend_line(grouped[{:other_state, :female}] || [])
      }
    }
  end

  defp format_trend_line(cutoffs) do
    cutoffs
    |> Enum.group_by(& &1.year)
    |> Enum.map(fn {year, year_cutoffs} ->
      avg_opening =
        year_cutoffs |> Enum.map(& &1.opening_rank) |> Enum.sum() |> div(length(year_cutoffs))

      avg_closing =
        year_cutoffs |> Enum.map(& &1.closing_rank) |> Enum.sum() |> div(length(year_cutoffs))

      %{
        year: year,
        opening_rank: avg_opening,
        closing_rank: avg_closing
      }
    end)
    |> Enum.sort_by(& &1.year)
  end
end
