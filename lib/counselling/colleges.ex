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
  alias Counselling.NirfRanking

  @doc """
  Returns the list of colleges.

  ## Examples

      iex> list_colleges()
      [%College{}, ...]

  """

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
        order_by: [p.name]

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

  def create_nirf_ranking(attrs \\ %{}) do
    %NirfRanking{}
    |> NirfRanking.changeset(attrs)
    |> Repo.insert()
  end

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
    College
    |> build_query(filters)
    # |> sort_query(filters[:sort_by], filters[:sort_order])
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

      {:advanced_rank, advanced_rank}, query when not is_nil(advanced_rank) ->
        from q in query,
          where: q.class == :IIT,
          join: rc in RankCutoff,
          on: q.id == rc.college_id,
          group_by: q.id,
          having: type(^advanced_rank, :integer) <= fragment("MAX(?)", rc.closing_rank)

      {:mains_rank, mains_rank}, query when not is_nil(mains_rank) ->
        from q in query,
          where: q.class != :IIT,
          join: rc in RankCutoff,
          on: q.id == rc.college_id,
          group_by: q.id,
          having: type(^mains_rank, :integer) <= fragment("MAX(?)", rc.closing_rank)

      _, query ->
        from q in query,
          join: nr in NirfRanking,
          on: q.id == nr.college_id,
          order_by: nr.nirf_rank
    end)
  end

  def list_colleges() do
    College |> Repo.all()
  end

  def get_college_rank(college_id) do
    NirfRanking
    |> where(college_id: ^college_id)
    |> Repo.one()
  end

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
    Program |> Repo.all()
  end

  def get_programs_with_filter(filters) when is_map(filters) do
    Program
    |> build_query(filters)
    |> sort(filters[:sort_by], filters[:sort_order])
    |> Repo.all()
  end

  def sort(query, nil, nil), do: query

  def sort(query, sort_by, sort_order) do
    sort_by = String.to_existing_atom(sort_by)
    sort_order = String.to_existing_atom(sort_order)
    from c in query, order_by: [{^sort_order, field(c, ^sort_by)}]
  end

  def get_program!(program_id) do
    query =
      from c in Program,
        where: c.id == ^program_id,
        select: c

    Repo.one(query) |> Repo.preload(:colleges)
  end

  #############################################################
  def program_query(program_id) do
    from rc in RankCutoff,
      join: c in College,
      on: rc.college_id == c.id,
      join: p in Program,
      on: rc.program_id == p.id,
      where: p.id == ^program_id,
      select: %{
        id: c.id,
        college: c,
        year: rc.year,
        quota: rc.quota,
        category: rc.category,
        opening_rank: rc.opening_rank,
        closing_rank: rc.closing_rank
      }
  end

  def get_program_data(filters, program_id) when is_map(filters) do
    program_query(program_id)
    |> build_query_2(filters)
    |> sort_2(filters[:sort_by], filters[:sort_order])
    |> Repo.all()
  end

  def build_query_2(query, filters) do
    Enum.reduce(filters, query, fn
      {:class, classes}, query when classes == [] ->
        query

      {:class, classes}, query when is_list(classes) ->
        from [rc, c, p] in query, where: c.class in ^classes

      {:category, categories}, query when is_list(categories) ->
        from [rc, c, p] in query, where: rc.category in ^categories

      # {:quota, quotas}, query when is_list(quotas) ->
      #   from [rc, c, p] in query, where: rc.quota in ^quotas

      _, query ->
        query
    end)
  end

  def count_colleges_with_no_programs do
    query =
      from c in College,
        left_join: p in assoc(c, :programs),
        where: is_nil(p.id),
        distinct: c.id,
        select: c.name

    Repo.all(query)
  end

  def sort_2(query, nil, nil), do: query

  def sort_2(query, sort_by, sort_order) do
    sort_by = String.to_existing_atom(sort_by)
    sort_order = String.to_existing_atom(sort_order)
    # Write more elegantly
    case sort_by do
      :name -> from [rc, c, p] in query, order_by: [{^sort_order, field(c, ^sort_by)}]
      # :nirfrank -> from [rc, c, p] in query, order_by: [{^sort_order, field(c, ^sort_by)}]
      :opening_rank -> from [rc, c, p] in query, order_by: [{^sort_order, field(rc, ^sort_by)}]
      :closing_rank -> from [rc, c, p] in query, order_by: [{^sort_order, field(rc, ^sort_by)}]
      :location -> from [rc, c, p] in query, order_by: [{^sort_order, field(c, ^sort_by)}]
      :quota -> from [rc, c, p] in query, order_by: [{^sort_order, field(rc, ^sort_by)}]
      :category -> from [rc, c, p] in query, order_by: [{^sort_order, field(rc, ^sort_by)}]
      _ -> query
    end
  end

  def get_program_data(program_id) do
    program_query(program_id)
    |> Repo.all()
  end

  ############################################################
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
      {"tr", [{"class", "text-white bg-secondary"}], _} ->
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
