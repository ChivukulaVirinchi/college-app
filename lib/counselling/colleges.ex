defmodule Counselling.Colleges do
  @moduledoc """
  The Colleges context.
  """

  import Ecto.Query, warn: false
  alias Counselling.Repo

  alias Counselling.Colleges.College
  alias Counselling.Branches.Branch
  alias Counselling.Branches

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
  def get_college!(id), do: Repo.get!(College, id) |> Repo.preload(:branches)

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
    |> Repo.all()
    |> Repo.preload(:branches)

    # |> sort_query(sort)
    # |> Repo.preload(:branches)
  end

  def build_query(query, filters) do
    Enum.reduce(filters, query, fn
      {:name, name}, query ->
        pattern = "%#{name}%"
        from q in query, where: ilike(q.name, ^pattern)

      {:location, location}, query ->
        pattern = "%#{location}%"
        from q in query, where: ilike(q.location, ^pattern)

        # {:class, class}, query ->
        #   pattern = "%#{class}%"
        #   from q in query, where: ilike(q.class, ^pattern)
    end)
  end

  # def filter_query(query, filters) do
  #   from(p in query,
  #     where: ilike(p.name, ^"%#{filters.name}%")

  #     # or_where: ilike(p.location, ^"%#{filters.location}%")
  #   )
  # end

  def list_colleges() do
    Repo.all(from(d in College, order_by: d.nirfrank))
  end

  # defp sort_query(query, nil), do: query
  # defp sort_query(query, "name_asc"), do: query |> order_by([c], asc: c.name)
  # defp sort_query(query, "name_desc"), do: query |> order_by([c], desc: c.name)
  # defp sort_query(query, "nirfrank_asc"), do: query |> order_by([c], asc: c.nirfrank)
  # defp sort_query(query, "nirfrank_desc"), do: query |> order_by([c], desc: c.nirfrank)
  #################################################

  def list_branches do
    Repo.all(Branch) |> Repo.preload(:colleges)
  end

  def get_branch!(id), do: Repo.get!(Branch, id) |> Repo.preload(:colleges)

  def create_branch(attrs \\ %{}) do
    %Branch{}
    |> Branch.changeset(attrs)
    |> Repo.insert()
  end

  def update_branch(%Branch{} = branch, attrs) do
    branch
    |> Branch.changeset(attrs)
    |> Repo.update()
  end

  def delete_branch(%Branch{} = branch) do
    Repo.delete(branch)
  end

  def change_branch(%Branch{} = branch, attrs \\ %{}) do
    Branch.changeset(branch, attrs)
  end

  # New functions for managing the many-to-many relationship
  def add_branch_to_college(college, branch) do
    college
    |> Repo.preload(:branches)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:branches, [branch | college.branches])
    |> Repo.update()
  end

  def remove_branch_from_college(college, branch) do
    college
    |> Repo.preload(:branches)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:branches, Enum.filter(college.branches, &(&1.id != branch.id)))
    |> Repo.update()
  end
end
