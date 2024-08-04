defmodule Counselling.CollegeBranches.CollegeBranch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_branches" do
    belongs_to :college, Counselling.Colleges.College
    belongs_to :branch, Counselling.Branches.Branch
    has_many :rank_cutoffs, Counselling.CollegeBranches.RankCutoff
    timestamps()
  end

  @doc false
  def changeset(college_branch, attrs) do
    college_branch
    |> cast(attrs, [:college_id, :branch_id])
    |> validate_required([:college_id, :branch_id])
    |> foreign_key_constraint(:college_id)
    |> foreign_key_constraint(:branch_id)

    # |> unique_constraint(:college_id, :branch_id)
  end
end
