defmodule Counselling.Colleges do
  import Ecto.Query

  alias Counselling.{
    Colleges.College,
    CollegePrograms.CollegeProgram,
    Ranks.RankCutoff,
    Programs.Program,
    NirfRanking,
    Repo
  }

  @latest_year Josaa.latest_year()

  def list_colleges() do
    from c in College,
      join: cp in CollegeProgram,
      on: c.id == cp.college_id,
      join: rc in RankCutoff,
      on:
        rc.college_program_id == cp.id and rc.year == ^@latest_year and
          rc.gender == :gender_neutral and rc.seat_type == :open and
          rc.quota in [:all_india, :other_state],
      join: nr in NirfRanking,
      on: c.id == nr.college_id and nr.year == ^@latest_year,
      group_by: [c.id, c.name, c.established_year, c.campus_area, c.location, nr.nirf_rank],
      order_by: [asc: nr.nirf_rank],
      select: %{
        rank: nr.nirf_rank,
        programs: count(cp.id),
        college: c
      }
  end

  def list_all_colleges_sitemap() do
    Repo.all(from c in College, select: %{id: c.id, slug: c.slug})
  end

  def list_all_college_programs_sitemap() do
    from(cp in CollegeProgram,
      join: c in College,
      on: c.id == cp.college_id,
      join: p in Program,
      on: p.id == cp.program_id,
      select: %{
        college_id: c.id,
        college_slug: c.slug,
        program_id: p.id,
        program_slug: p.slug
      }
    )
    |> Repo.all()
  end

  def count_colleges, do: Repo.aggregate(College, :count)

  def get_college!(id) do
    Repo.get!(College, id)
    |> Repo.preload(:nirf_rankings)
  end

  def fetch_colleges([]), do: []

  def fetch_colleges(ids) when is_list(ids) do
    colleges =
      from(c in College, where: c.id in ^ids, preload: :nirf_rankings)
      |> Repo.all()
      |> Map.new(&{&1.id, &1})

    Enum.map(ids, &Map.get(colleges, &1)) |> Enum.reject(&is_nil/1)
  end

  def get_college_programs(id) do
    from c in College,
      as: :college,
      join: cp in CollegeProgram,
      as: :college_program,
      on: cp.college_id == c.id,
      join: p in Program,
      as: :program,
      on: p.id == cp.program_id,
      join: rc in RankCutoff,
      as: :rank_cutoff,
      on: rc.college_program_id == cp.id,
      where:
        c.id == ^id and
          rc.year == ^@latest_year,
      order_by: [asc: p.name],
      select: %{
        college: c,
        program: p,
        opening_rank: rc.opening_rank,
        closing_rank: rc.closing_rank,
        gender: rc.gender,
        seat_type: rc.seat_type,
        quota: rc.quota,
        degree_type: p.degree_type
      }
  end

  def create_college(attrs \\ %{}) do
    %College{}
    |> College.changeset(attrs)
    |> Repo.insert()
  end

  def class(college_name) do
    cond do
      String.contains?(college_name, "Indian Institute of Technology") ->
        :IIT

      String.contains?(college_name, "National Institute of Technology") ->
        :NIT

      String.contains?(college_name, "Indian Institute of Engineering Science") ->
        :NIT

      String.contains?(college_name, "Indian Institute of Information Technology") ->
        :IIIT

      true ->
        :GFTI
    end
  end

  def create_college_program(college_id, program_id) do
    %CollegeProgram{}
    |> CollegeProgram.changeset(%{college_id: college_id, program_id: program_id})
    |> Repo.insert()
  end

  def get_college_program(college_id, program_id) do
    CollegeProgram
    |> where(
      [college_program],
      college_program.college_id == ^college_id and college_program.program_id == ^program_id
    )
    |> Repo.all()
    |> Repo.preload(:college)
    |> Repo.preload(:program)
  end

  def get_college_program_id(college_id, program_id) do
    query =
      from cp in CollegeProgram,
        where: cp.college_id == ^college_id and cp.program_id == ^program_id,
        select: cp.id

    Repo.one(query)
  end

  def create_rank_cutoff(college_id, program_id, cutoff_params) do
    params =
      Map.merge(cutoff_params, %{
        college_program_id: get_college_program_id(college_id, program_id)
      })

    %RankCutoff{}
    |> RankCutoff.changeset(params)
    |> Repo.insert()
  end

  def create_rank_cutoff_including_college_program(college_id, program_id, cutoff_params) do
    if get_college_program(college_id, program_id) == [] do
      {:ok, _college_program} =
        create_college_program(college_id, program_id)

      create_rank_cutoff(college_id, program_id, cutoff_params)
    else
      create_rank_cutoff(college_id, program_id, cutoff_params)
    end
  end

  def process_table_row(row, year) do
    case row do
      {"tr", [{"class", "text-white bg-secondary"}], _} ->
        {:skip, "Skipping header row"}

      {"tr", _, [{"th", _, _} | _]} ->
        {:skip, "Skipping header row"}

      {"tr", _, data} when length(data) == 7 ->
        [college_name, program_name, quota, seat_type, gender, opening_rank, closing_rank] =
          Enum.map(data, &extract_row_content/1)

        if Enum.any?([college_name, program_name, quota, seat_type, gender, opening_rank, closing_rank], &(&1 == "")) do
          {:skip, "Skipping row with empty fields"}
        else
          create_assocs(
            college_name,
            program_name,
            quota,
            seat_type,
            gender,
            opening_rank,
            closing_rank,
            year
          )
        end

      _ ->
        {:error, "Invalid row format"}
    end
  end

  def extract_row_content({"td", _, content}) do
    content
    |> List.flatten()
    |> Enum.find_value("", fn
      string when is_binary(string) -> string
      {"span", _, [value]} when is_binary(value) -> value
      _ -> nil
    end)
    |> String.trim()
  end

  def create_assocs(
        college_name,
        program_name,
        quota,
        seat_type,
        gender,
        opening_rank,
        closing_rank,
        year
      ) do
    cutoff_params = %{
      quota: parse_quota(quota),
      gender: parse_gender(gender),
      seat_type: Josaa.seat_type_atom(seat_type),
      opening_rank: parse_rank(opening_rank),
      closing_rank: parse_rank(closing_rank),
      year: year
    }

    with {:ok, college_id} <- get_college_id(college_name),
         {:ok, program_id} <- get_program_id(program_name) do
      create_rank_cutoff_including_college_program(college_id, program_id, cutoff_params)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_program_id(program_name) do
    details =
      program_name
      |> String.trim()
      |> String.replace(~r/\s+/, " ")
      |> String.replace("&", "and")
      |> Josaa.parse_degree_info()

    case Repo.get_by(Program,
           name: details.name,
           duration: details.duration,
           degree_type: details.degree_type
         ) do
      nil -> {:error, "Program not found: #{program_name}"}
      program -> {:ok, program.id}
    end
  end

  # Maps JOSAA college names that differ from our canonical names
  @college_aliases %{
    "Indian Institute of Information Technology Manipur" =>
      "INDIAN INSTITUTE OF INFORMATION TECHNOLOGY SENAPATI MANIPUR",
    "Institute of Technology, Guru Ghasidas Vishwavidyalaya (A Central University), Bilaspur, (C.G.)" =>
      "School of Studies of Engineering and Technology, Guru Ghasidas Vishwavidyalaya, Bilaspur"
  }

  def get_college_id(college_name) do
    normalized =
      college_name
      |> String.trim()
      |> String.replace(~r/\s+/, " ")
      |> String.replace("&", "and")

    # Check alias map first
    canonical = Map.get(@college_aliases, normalized, normalized)

    case Repo.get_by(College, name: canonical) do
      %College{id: id} ->
        {:ok, id}

      nil ->
        # Fallback: try original normalized name
        case Repo.get_by(College, name: normalized) do
          %College{id: id} -> {:ok, id}
          nil -> {:error, "College not found: #{college_name}"}
        end
    end
  end

  def parse_quota("AI"), do: :all_india
  def parse_quota("HS"), do: :home_state
  def parse_quota("OS"), do: :other_state
  def parse_quota("GO"), do: :go
  def parse_quota("JK"), do: :jk
  def parse_quota("LA"), do: :la

  def parse_gender("Gender-Neutral"), do: :gender_neutral
  def parse_gender("Female-only (including Supernumerary)"), do: :female
  def parse_gender(_), do: :gender_neutral

  def parse_rank(rank_string) do
    rank_string
    |> String.replace(~r/[^\d]/, "")
    |> String.to_integer()
  end

  def get_college_rank(college_id) do
    NirfRanking
    |> where(college_id: ^college_id, year: ^@latest_year)
    |> Repo.one()
  end

  @doc "Lightweight list for the compare command palette (id, name, location, class, nirf_rank)."
  def list_colleges_summary do
    from(c in College,
      left_join: nr in NirfRanking,
      on: nr.college_id == c.id and nr.year == ^@latest_year,
      order_by: [asc: fragment("COALESCE(?, 999)", nr.nirf_rank), asc: c.name],
      select: %{
        id: c.id,
        name: c.name,
        location: c.location,
        class: c.class,
        nirf_rank: nr.nirf_rank
      }
    )
    |> Repo.all()
  end

  def get_similar_colleges(college_id) do
    current_rank =
      from(nr in NirfRanking,
        where: nr.college_id == ^college_id and nr.year == ^@latest_year,
        select: nr.nirf_rank
      )
      |> Repo.one()

    query =
      from c in College,
        join: nr in NirfRanking,
        on: nr.college_id == c.id and nr.year == ^@latest_year,
        where: c.id != ^college_id,
        where:
          nr.nirf_rank >= ^max(1, current_rank - 15) and nr.nirf_rank <= ^(current_rank + 15),
        limit: 3,
        select: %{college: c, rank: nr.nirf_rank}

    Repo.all(query)
  end
end
