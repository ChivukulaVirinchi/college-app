defmodule Counselling.CollegePrograms.CollegeProgram do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_programs" do
    belongs_to :college, Counselling.Colleges.College
    belongs_to :program, Counselling.Programs.Program
    has_many :rank_cutoffs, Counselling.Ranks.RankCutoff
    timestamps()
  end

  def changeset(branch_program, attrs) do
    branch_program
    |> cast(attrs, [:college_id, :program_id])
    |> validate_required([:college_id, :program_id])
    |> unique_constraint([:college_id, :program_id])
  end
end
