defmodule Counselling.Programs.Program do
  use Ecto.Schema
  import Ecto.Changeset

  schema "programs" do
    field :name, :string
    field :duration, :integer
    field :degree_type, :string

    many_to_many :colleges, Counselling.Colleges.College, join_through: "college_programs"

    has_many :rank_cutoffs, Counselling.Ranks.RankCutoff

    timestamps()
  end

  @doc false
  def changeset(program, attrs) do
    program
    |> cast(attrs, [:name, :duration, :degree_type])
    |> validate_required([:name, :duration, :degree_type])
    |> validate_number(:duration, greater_than: 0)
    |> unique_constraint([:name, :duration, :degree_type])
  end
end
