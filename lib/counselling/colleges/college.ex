defmodule Counselling.Colleges.College do
  use Ecto.Schema
  import Ecto.Changeset

  schema "colleges" do
    field :name, :string
    field :location, :string
    field :established_year, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(college, attrs) do
    college
    |> cast(attrs, [:name, :established_year, :location])
    |> validate_required([:name, :established_year, :location])
  end
end
