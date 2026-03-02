defmodule Counselling.Programs do
  import Ecto.Query, warn: false
  alias Counselling.Ranks.RankCutoff
  alias Counselling.NirfRanking
  alias Counselling.Colleges.College
  alias Counselling.CollegePrograms.CollegeProgram
  alias Counselling.{Programs.Program, Repo}

  @latest_year Josaa.latest_year()

  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  def list_programs() do
    Program
  end

  def list_all_programs_sitemap() do
    Repo.all(from p in Program, select: %{id: p.id, slug: p.slug})
  end

  def get_program!(id) do
    Repo.get!(Program, id)
  end

  def get_college_count(id) do
    list_colleges(id)
    |> exclude(:select)
    |> exclude(:order_by)
    |> select([_, _, c, _, _], count(c.id))
    |> Repo.one()
  end

  def list_colleges(id, seat_type \\ :open) do
    from p in Program,
      join: cp in CollegeProgram,
      on: cp.program_id == p.id,
      join: c in College,
      as: :college,
      on: c.id == cp.college_id,
      where: p.id == ^id,
      join: nr in NirfRanking,
      on: nr.college_id == c.id and nr.year == ^@latest_year,
      join: rc in RankCutoff,
      on:
        rc.college_program_id == cp.id and rc.year == ^@latest_year and
          rc.gender == :gender_neutral and rc.seat_type == ^seat_type and
          rc.quota in [:all_india, :other_state],
      order_by: [asc: nr.nirf_rank],
      select: %{
        program: p,
        college: c,
        rank: nr.nirf_rank,
        opening_rank: rc.opening_rank,
        closing_rank: rc.closing_rank,
        seat_type: rc.seat_type
      }
  end

  def get_program_by_name(name) do
    Repo.get_by(Program, name: name)
    |> Repo.one()
  end

  def get_common_programs(college_ids) when length(college_ids) == 1, do: []

  def get_common_programs(college_ids) when is_list(college_ids) do
    from(cp in CollegeProgram,
      join: p in Program,
      on: cp.program_id == p.id,
      join: c in College,
      on: c.id == cp.college_id,
      where: c.id in ^college_ids,
      group_by: [p.id, p.name],
      having: count(c.id) == ^length(college_ids),
      select: %{
        id: p.id,
        name: p.name
      }
    )
    |> Repo.all()
  end

  def list_program_types() do
    from(p in Program,
      distinct: p.degree_type,
      select: p.degree_type,
      order_by: [
        asc: fragment("CASE WHEN ? = 'Bachelor of Technology' THEN 0 ELSE 1 END", p.degree_type),
        asc: p.degree_type
      ]
    )
    |> Repo.all()
  end
end
