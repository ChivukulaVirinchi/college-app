defmodule Counselling.Colleges do
  @moduledoc """
  The Colleges context.
  """

  import Ecto.Query, warn: false
  alias Counselling.Repo

  alias Counselling.Colleges.College

  alias Counselling.Ranks.RankCutoff
  alias Counselling.CollegePrograms.CollegeProgram
  alias Counselling.Programs.Program

  @doc """
  Returns the list of colleges.

  ## Examples

      iex> list_colleges()
      [%College{}, ...]

  """

  # def list_colleges(params) when is_map(params) do
  #   Flop.validate_and_run(College, params, for: College)
  # end

  @doc """
  Gets a single college.

  Raises `Ecto.NoResultsError` if the College does not exist.

  ## Examples

      iex> get_college!(123)
      %College{}

      iex> get_college!(456)
      ** (Ecto.NoResultsError)

  """
  def get_college_by_id!(college_id) do
    College
    |> where(id: ^college_id)
    |> Repo.one()
  end

  def get_college_program_rank_data_by_id(college_id) do
    query =
      from rc in RankCutoff,
        join: c in College,
        on: rc.college_id == c.id and c.id == ^college_id,
        join: p in Program,
        on: rc.program_id == p.id,
        select: %{
          name: p.name,
          duration: p.duration,
          degree_type: p.degree_type,
          year: rc.year,
          quota: rc.quota,
          category: rc.category,
          opening_rank: rc.opening_rank,
          closing_rank: rc.closing_rank
        },
        order_by: [c.name, p.name, desc: rc.year]

    %{college: get_college_by_id!(college_id), programs: Repo.all(query)}
  end

  @doc """
  Creates a college.

  ## Examples

      iex> create_college(%{field: value})
      {:ok, %College{}}

      iex> create_college(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_college(attrs \\ %{}) do
    %College{}
    |> College.changeset(attrs)
    |> Repo.insert()
  end

  def get_class(college_name) do
    cond do
      String.contains?(college_name, "Indian Institute of Technology") -> :IIT
      String.contains?(college_name, "National Institute of Technology") -> :NIT
      String.contains?(college_name, "Indian Institute of Engineering Science") -> :NIT
      String.contains?(college_name, "Indian Institute of Information Technology") -> :IIIT
      true -> :GFTI
    end
  end

  # def get_nirfrank(college_name) do

  # end
  @doc """
  Updates a college.

  ## Examples

      iex> update_college(college, %{field: new_value})
      {:ok, %College{}}

      iex> update_college(college, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_college(%College{} = college, attrs) do
    college
    |> College.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a college.

  ## Examples

      iex> delete_college(college)
      {:ok, %College{}}

      iex> delete_college(college)
      {:error, %Ecto.Changeset{}}

  """
  def delete_college(%College{} = college) do
    Repo.delete(college)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking college changes.

  ## Examples

      iex> change_college(college)
      %Ecto.Changeset{data: %College{}}

  """
  def change_college(%College{} = college, attrs \\ %{}) do
    College.changeset(college, attrs)
  end

  ################################################

  def get_colleges_with_filter(filters) when is_map(filters) do
    IO.inspect(filters, label: "Received Filters")

    College
    |> build_query(filters)
    |> Repo.all()

    # |> sort_query(sort)
  end

  def build_query(query, filters) do
    Enum.reduce(filters, query, fn
      {:name, name}, query ->
        pattern = "%#{name}%"
        from q in query, where: ilike(q.name, ^pattern)

      {:location, location}, query ->
        pattern = "%#{location}%"
        from q in query, where: ilike(q.location, ^pattern)

      {:class, classes}, query when is_list(classes) ->
        from q in query, where: q.class in ^classes

      {:advanced_rank, advanced_rank}, query ->
        case advanced_rank do
          nil ->
            query

          string when is_binary(string) ->
            case Integer.parse(string) do
              {rank, _} ->
                from q in query,
                  where: q.class == :GFTI,
                  join: p in assoc(q, :programs),
                  join: rc in assoc(p, :rank_cutoffs),
                  group_by: q.id,
                  having: ^rank <= fragment("MAX(?)", rc.closing_rank)

              :error ->
                IO.puts("Error parsing integer: #{string}")
                query
            end
        end

      _, query ->
        query
    end)
  end

  def list_colleges() do
    Repo.all(from(d in College, order_by: d.nirfrank))
  end

  # defp sort_query(query, nil), do: query
  # defp sort_query(query, "name_asc"), do: query |> order_by([c], asc: c.name)
  # defp sort_query(query, "name_desc"), do: query |> order_by([c], desc: c.name)
  # defp sort_query(query, "nirfrank_asc"), do: query |> order_by([c], asc: c.nirfrank)
  # defp sort_query(query, "nirfrank_desc"), do: query |> order_by([c], desc: c.nirfrank)
  #################################################

  def get_college!(college_name) do
    query =
      from c in College,
        where: c.name == ^college_name,
        select: c.id

    case Repo.all(query) do
      [college_id] -> {:ok, college_id}
      [] -> {:error, "College not found: #{college_name}"}
    end
  end

  ############################################################
  # Programs Context Functions
  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert()
  end

  def list_programs() do
    Repo.all(from(d in Program, order_by: d.name))
  end

  def get_program!(program_name) do
    query =
      from c in Program,
        where: c.name == ^program_name,
        select: c

    {:ok, Repo.all(query)}
  end

  ############################################################
  def create_college_program(college_id, program_id) do
    %CollegeProgram{}
    |> CollegeProgram.changeset(%{college_id: college_id, program_id: program_id})
    |> Repo.insert()
  end

  def list_college_programs() do
    Repo.all(from(d in CollegeProgram, order_by: d.college_id))
    |> Repo.preload(:college)
    |> Repo.preload(:program)

    # |> Repo.preload(:rank_cutoffs)
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

  def create_rank_cutoff(college_id, program_id, cutoff_params) do
    params = Map.merge(cutoff_params, %{college_id: college_id, program_id: program_id})

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

  def process_table_row(row) do
    case row do
      {"tr", [{"class", "bg-secondary text-white"}], _} ->
        {:skip, "Skipping header row"}

      {"tr", _, cells} when length(cells) == 7 ->
        [college_name, program_name, quota, seat_type, gender, opening_rank, closing_rank] =
          Enum.map(cells, &extract_cell_content/1)

        if seat_type == "OPEN" do
          process_row_data(college_name, program_name, quota, gender, opening_rank, closing_rank)
        else
          {:skip, "Not an OPEN category record"}
        end

      _ ->
        {:error, "Invalid row format"}
    end
  end

  def extract_cell_content({"td", _, content}) do
    content
    |> List.flatten()
    |> Enum.find_value("", fn
      string when is_binary(string) -> string
      {"span", _, [value]} when is_binary(value) -> value
      _ -> nil
    end)
    |> String.trim()
  end

  # this
  def process_row_data(college_name, program_name, quota, gender, opening_rank, closing_rank) do
    with {:ok, college_id} <- get_college!(college_name),
         {:ok, program} <- get_program(program_name),
         {:ok, cutoff_params} <- create_cutoff_params(quota, gender, opening_rank, closing_rank) do
      create_rank_cutoff_including_college_program(college_id, program.id, cutoff_params)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # This
  # def get_college(name) do
  #   case Repo.get_by(College, name: name) do
  #     nil -> {:error, "College not found: #{name}"}
  #     college -> {:ok, college}
  #   end
  # end

  # This
  def get_program(program_name) do
    # Extract program name without duration and degree type
    details = Josaa.parse_degree_info(program_name)

    ### Change this
    case Repo.get_by(Program,
           name: details.name,
           duration: details.duration,
           degree_type: details.degree_type
         ) do
      nil -> {:error, "Program not found: #{program_name}"}
      program -> {:ok, program}
    end
  end

  def create_cutoff_params(quota, gender, opening_rank, closing_rank) do
    {:ok,
     %{
       quota: parse_quota(quota),
       category: parse_gender(gender),
       opening_rank: String.to_integer(opening_rank),
       closing_rank: String.to_integer(closing_rank),
       year: 2024
     }}
  end

  def parse_quota("AI"), do: :all_india
  def parse_quota("HS"), do: :home_state
  def parse_quota("OS"), do: :other_state
  def parse_quota(_), do: :all_india

  def parse_gender("Gender-Neutral"), do: :gender_neutral
  def parse_gender("Female-only (including Supernumerary)"), do: :female
  def parse_gender(_), do: :gender_neutral
end
