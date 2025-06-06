defmodule Counselling.Colleges.College do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Counselling.Colleges.Permalink, autogenerate: true}

  schema "colleges" do
    field :name, :string
    field :location, :string
    field :established_year, :integer
    field :class, Ecto.Enum, values: [:IIT, :NIT, :IIIT, :GFTI], default: :GFTI
    field :website, :string
    field :campus_area, :integer
    field :slug, :string
    field :photo_path, :string
    field :description, :string

    many_to_many :programs, Counselling.Programs.Program, join_through: "college_programs"

    has_many :nirf_rankings, Counselling.NirfRanking

    timestamps()
  end

  @doc false
  def changeset(college, attrs) do
    college
    |> cast(attrs, [
      :name,
      :location,
      :established_year,
      :class,
      :website,
      :photo_path,
      :description,
      :campus_area
    ])
    |> validate_required([:name, :established_year, :location, :class, :description])
    |> unique_constraint(:name)
    |> slugify_name()
  end

  defp slugify_name(changeset) do
    case fetch_change(changeset, :name) do
      {:ok, new_name} -> put_change(changeset, :slug, slugify(new_name))
      :error -> changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace([" ", ",", "  "], "-")
  end
end
