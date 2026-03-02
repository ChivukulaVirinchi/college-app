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
      seat_type: %{
        label: "Category",
        sortable: false,
        renderer: &process_seat_type/1
      },
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
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.gender == :gender_neutral),
          default: true
        }),
      female_filter:
        Boolean.new(:gender, "gender-filter", %{
          label: "Female",
          condition: dynamic([_, _, _, rank_cutoff: rc], rc.gender == :female)
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

  @quota_filter_keys [:hs, :all_india, :os]

  # IITs only have all_india — no quota filter needed
  def filters_for(:IIT), do: Keyword.drop(filters(), @quota_filter_keys)
  # NITs have home_state + other_state — drop redundant all_india
  def filters_for(:NIT), do: Keyword.drop(filters(), [:all_india])
  # IIITs/GFTIs only have all_india — no quota filter needed
  def filters_for(_class), do: Keyword.drop(filters(), @quota_filter_keys)

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
      rank == 500 -> "—"
      rank == 250 -> "201–300"
      rank == 175 -> "151–200"
      rank == 125 -> "101–150"
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

  defp type_badge_color(:IIT),
    do: "bg-violet-100 text-violet-700 dark:bg-violet-500/15 dark:text-violet-400"

  defp type_badge_color(:NIT),
    do: "bg-blue-100 text-blue-700 dark:bg-blue-500/15 dark:text-blue-400"

  defp type_badge_color(:IIIT),
    do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-500/15 dark:text-emerald-400"

  defp type_badge_color(:GFTI),
    do: "bg-orange-100 text-orange-700 dark:bg-orange-500/15 dark:text-orange-400"

  defp type_badge_color(_),
    do: "bg-stone-100 text-stone-600 dark:bg-zinc-800 dark:text-zinc-400"
end
