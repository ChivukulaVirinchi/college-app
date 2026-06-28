defmodule Counselling.Ranks.RankCutoff do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rank_cutoffs" do
    field :opening_rank, :integer
    field :closing_rank, :integer
    field :quota, Ecto.Enum, values: [:home_state, :other_state, :all_india, :go, :jk, :la]
    field :gender, Ecto.Enum, values: [:gender_neutral, :female]

    field :seat_type, Ecto.Enum,
      values: [
        :open,
        :obc_ncl,
        :sc,
        :st,
        :ews,
        :open_pwd,
        :obc_ncl_pwd,
        :sc_pwd,
        :st_pwd,
        :ews_pwd
      ]

    field :year, :integer

    belongs_to :college_program, Counselling.CollegePrograms.CollegeProgram

    timestamps()
  end

  def changeset(rank_cutoff, attrs) do
    rank_cutoff
    |> cast(attrs, [
      :opening_rank,
      :closing_rank,
      :quota,
      :gender,
      :seat_type,
      :year,
      :college_program_id
    ])
    |> validate_required([
      :opening_rank,
      :closing_rank,
      :quota,
      :gender,
      :seat_type,
      :year,
      :college_program_id
    ])
    |> validate_number(:opening_rank, greater_than_or_equal_to: 1)
    |> validate_number(:year, greater_than_or_equal_to: 2000)
    |> unique_constraint([:year, :college_program_id, :quota, :gender, :seat_type])
  end
end
