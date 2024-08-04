defmodule Counselling.Ranks.RankCutoff do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rank_cutoffs" do
    field :opening_rank, :integer
    field :closing_rank, :integer
    field :quota, Ecto.Enum, values: [:home_state, :other_state, :all_india]
    field :category, Ecto.Enum, values: [:gender_neutral, :female]
    field :year, :integer
    belongs_to :college, Counselling.Colleges.College
    belongs_to :program, Counselling.Programs.Program

    timestamps()
  end

  def changeset(rank_cutoff, attrs) do
    rank_cutoff
    |> cast(attrs, [
      :opening_rank,
      :closing_rank,
      :quota,
      :category,
      :year,
      :college_id,
      :program_id
    ])
    |> validate_required([
      :opening_rank,
      :closing_rank,
      :quota,
      :category,
      :year,
      :college_id,
      :program_id
    ])
    |> validate_number(:opening_rank, greater_than_or_equal_to: 1)
    # |> validate_number(:closing_rank, greater_than_or_equal_to: :opening_rank)
    |> validate_number(:year, greater_than_or_equal_to: 2000)
    |> unique_constraint([:year, :college_id, :program_id, :quota, :category])
  end
end
