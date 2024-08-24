defmodule Counselling.NirfRanking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nirf_rankings" do
    field :nirf_rank, :integer, default: 125
    field :year, :integer
    belongs_to :college, Counselling.Colleges.College

    timestamps()
  end

  @doc false
  def changeset(nirf_ranking, attrs) do
    nirf_ranking
    |> cast(attrs, [:nirf_rank, :year, :college_id])
    |> validate_required([:nirf_rank, :year, :college_id])
  end
end
