defmodule Counselling.NirfRankings do
  alias Counselling.{NirfRanking, Repo, Colleges}

  def create_ranking(attrs \\ %{}) do
    %NirfRanking{}
    |> NirfRanking.changeset(attrs)
    |> Repo.insert()
  end

  def update_ranking(college_name, year, rank) do
    {:ok, college_id} = Colleges.get_college_id(college_name)

    case Repo.get_by(NirfRanking, college_id: college_id, year: year) do
      nil ->
        {:error, :not_found}

      ranking ->
        ranking
        |> NirfRanking.changeset(%{nirf_rank: rank})
        |> Repo.update()
    end
  end
end
