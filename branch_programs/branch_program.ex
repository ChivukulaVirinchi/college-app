defmodule Counselling.BranchPrograms.BranchProgram do
  use Ecto.Schema
  import Ecto.Changeset

  schema "branch_programs" do
    belongs_to :college, Counselling.Colleges.College
    belongs_to :program, Counselling.Programs.Program
    belongs_to :branch, Counselling.Branches.Branch

    timestamps()
  end

  def changeset(branch_program, attrs) do
    branch_program
    |> cast(attrs, [:college_id, :program_id, :branch_id])
    |> validate_required([:college_id, :program_id, :branch_id])
    |> unique_constraint([:college_id, :program_id, :branch_id])
  end
end
