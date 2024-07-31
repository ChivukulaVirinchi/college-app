defmodule Counselling.Branches.Branch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "branches" do
    field :name, :string

    many_to_many :colleges, Counselling.Colleges.College,
      join_through: Counselling.Colleges.CollegeBranch

    timestamps()
  end

  def changeset(branch, attrs) do
    branch
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
