defmodule CounsellingWeb.CollegeLive.Show do
  use CounsellingWeb, :live_view
  use LiveTable.LiveResource

  alias Counselling.Colleges

  @latest_year Josaa.latest_year()

  @impl true
  def mount(params, _session, socket) do
    [id_str | _] = String.split(params["college"], "-")
    id = String.to_integer(id_str)
    college = Colleges.get_college!(id)

    socket =
      socket
      |> assign(:data_provider, {Colleges, :get_college_programs, [id]})
      |> assign(:page_title, "#{college.name} - Programs & Cutoffs")
      |> assign(
        :meta_description,
        "#{college.name} engineering programs, JEE cutoffs and NIRF rankings. Check admission chances based on your rank."
      )
      |> assign(:college, college)
      |> assign(:similar_colleges, Colleges.get_similar_colleges(id))
      |> assign(:latest_year, @latest_year)

    {:ok, socket}
  end

  def fields do
    [
      program: %{
        label: "Name",
        sortable: false,
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
      gender: %{label: "Gender", sortable: false, renderer: &process_gender/1},
      seat_type: %{label: "Seat Type", sortable: false, renderer: &process_seat_type/1},
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
      }
    ]
  end

  def filters do
    [
      gender_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Gender Neutral",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.gender == :gender_neutral)
        }),
      female_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Female",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.gender == :female)
        }),
      open_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "OPEN",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :open)
        }),
      obc_ncl_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "OBC-NCL",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :obc_ncl)
        }),
      sc_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "SC",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :sc)
        }),
      st_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "ST",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :st)
        }),
      ews_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "EWS",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :ews)
        }),
      open_pwd_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "OPEN (PwD)",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :open_pwd)
        }),
      obc_ncl_pwd_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "OBC-NCL (PwD)",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :obc_ncl_pwd)
        }),
      sc_pwd_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "SC (PwD)",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :sc_pwd)
        }),
      st_pwd_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "ST (PwD)",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :st_pwd)
        }),
      ews_pwd_filter:
        Boolean.new(:seat_type, "seat-type-filter", %{
          label: "EWS (PwD)",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.seat_type == :ews_pwd)
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
    <.link
      class="hover:text-blue-400"
      navigate={~p"/colleges/#{@record.college}/programs/#{@program}"}
    >
      {@program.name}
    </.link>
    """
  end

  def nirf_helper(rank) do
    cond do
      rank == 500 -> "-"
      rank == 125 -> "125*"
      rank == 175 -> "175*"
      true -> "#{rank}"
    end
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
  defp process_seat_type(:open_pwd), do: "OPEN (PwD)"
  defp process_seat_type(:obc_ncl_pwd), do: "OBC-NCL (PwD)"
  defp process_seat_type(:sc_pwd), do: "SC (PwD)"
  defp process_seat_type(:st_pwd), do: "ST (PwD)"
  defp process_seat_type(:ews_pwd), do: "EWS (PwD)"
  defp process_seat_type(other), do: other |> to_string() |> String.upcase()
end
