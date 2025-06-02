defmodule Counselling.NirfRankings do
  alias Counselling.{NirfRanking, Repo}

  def create_ranking(attrs \\ %{}) do
    %NirfRanking{}
    |> NirfRanking.changeset(attrs)
    |> Repo.insert()
  end
end
