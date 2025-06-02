defmodule Counselling.Programs do
  import Ecto.Query, warn: false
  alias Counselling.Ranks.RankCutoff
  alias Counselling.NirfRanking
  alias Counselling.Colleges.College
  alias Counselling.CollegePrograms.CollegeProgram
  alias Counselling.{Programs.Program, Repo}

  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  def list_programs() do
    Program
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

  def list_colleges(id) do
    from p in Program,
      join: cp in CollegeProgram,
      on: cp.program_id == p.id,
      join: c in College,
      as: :college,
      on: c.id == cp.college_id,
      where: p.id == ^id,
      join: nr in NirfRanking,
      on: nr.college_id == c.id and nr.year == 2024,
      join: rc in RankCutoff,
      on:
        rc.college_program_id == cp.id and rc.year == 2024 and rc.category == :gender_neutral and
          rc.quota in [:all_india, :other_state],
      order_by: [asc: nr.nirf_rank],
      select: %{
        id: p.id,
        name: p.name,
        duration: p.duration,
        degree_type: p.degree_type,
        college_name: c.name,
        college_id: c.id,
        college_location: c.location,
        college_class: c.class,
        rank: nr.nirf_rank,
        opening_rank: rc.opening_rank,
        closing_rank: rc.closing_rank
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
end
