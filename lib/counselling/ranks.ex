defmodule Counselling.Ranks do
  import Ecto.Query, warn: false

  alias Counselling.CollegePrograms.CollegeProgram
  alias Counselling.Ranks.RankCutoff
  alias Counselling.Repo

  @latest_year Josaa.latest_year()

  def get_rank_cutoffs(college_id, program_id) do
    query =
      from rc in RankCutoff,
        join: cp in CollegeProgram,
        on: cp.id == rc.college_program_id,
        where: cp.college_id == ^college_id and cp.program_id == ^program_id,
        order_by: [asc: rc.opening_rank]

    Repo.all(query)
  end

  @doc """
  Base query for LiveTable data provider on the college-program page.
  Returns cutoffs for a specific college+program for the latest year.
  """
  def get_college_program_cutoffs(college_id, program_id) do
    from rc in RankCutoff,
      as: :rank_cutoff,
      join: cp in CollegeProgram,
      as: :college_program,
      on: cp.id == rc.college_program_id,
      where: cp.college_id == ^college_id and cp.program_id == ^program_id,
      where: rc.year == ^@latest_year,
      order_by: [asc: rc.opening_rank],
      select: %{
        opening_rank: rc.opening_rank,
        closing_rank: rc.closing_rank,
        gender: rc.gender,
        seat_type: rc.seat_type,
        quota: rc.quota
      }
  end

  @doc """
  Bulk-fetch rank cutoffs for multiple colleges × programs.

  Returns a map `%{{college_id, program_id} => %RankCutoff{}}` picking
  the best row per pair: prefer `:all_india` quota, fallback `:other_state`.
  """
  def get_compare_cutoffs(college_ids, program_ids, opts \\ []) do
    year = Keyword.fetch!(opts, :year)
    seat_type = Keyword.get(opts, :seat_type, :open)

    rows =
      from(rc in RankCutoff,
        join: cp in CollegeProgram,
        on: cp.id == rc.college_program_id,
        where: cp.college_id in ^college_ids,
        where: cp.program_id in ^program_ids,
        where: rc.year == ^year,
        where: rc.seat_type == ^seat_type,
        where: rc.gender == :gender_neutral,
        select: %{
          college_id: cp.college_id,
          program_id: cp.program_id,
          opening_rank: rc.opening_rank,
          closing_rank: rc.closing_rank,
          quota: rc.quota
        }
      )
      |> Repo.all()

    # Group by {college_id, program_id}, prefer :all_india, fallback :other_state
    rows
    |> Enum.group_by(fn r -> {r.college_id, r.program_id} end)
    |> Map.new(fn {key, group} ->
      best =
        Enum.find(group, fn r -> r.quota == :all_india end) ||
          Enum.find(group, fn r -> r.quota == :other_state end) ||
          hd(group)

      {key, best}
    end)
  end
end
