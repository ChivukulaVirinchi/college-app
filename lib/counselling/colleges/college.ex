defmodule Counselling.Colleges.College do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :established_year, :location, :nirfrank, :class],
    sortable: [:name, :established_year, :location, :nirfrank, :class]
    #  searchable: [:name, :established_year, :location, :nirfrank, :class]
  }

  schema "colleges" do
    field :name, :string
    field :location, :string
    field :established_year, :integer
    field :nirfrank, :integer
    field :class, Ecto.Enum, values: [:IIT, :NIT, :IIIT, :GFTI]
    field :link_to_website, :string
    field :campus_area, :integer

    many_to_many :branches, Counselling.Branches.Branch,
      join_through: Counselling.CollegeBranches.CollegeBranch

    timestamps()
  end

  @doc false
  def changeset(college, attrs) do
    college
    |> cast(attrs, [
      :name,
      :location,
      :established_year,
      :nirfrank,
      :class,
      :link_to_website,
      :campus_area
    ])
    |> validate_required([:name, :established_year, :location, :nirfrank, :class])
    |> unique_constraint(:name)
  end
end
