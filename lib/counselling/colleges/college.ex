defmodule Counselling.Colleges.College do
  use Ecto.Schema
  import Ecto.Changeset

  # @derive {Phoenix.Param, key: :slug}
  @primary_key {:id, Counselling.Colleges.Permalink, autogenerate: true}
  schema "colleges" do
    field :name, :string
    field :location, :string, default: "Chennai"
    field :established_year, :integer, default: 2000
    field :class, Ecto.Enum, values: [:IIT, :NIT, :IIIT, :GFTI], default: :GFTI
    field :link_to_website, :string, default: "https://www.google.com"
    field :campus_area, :integer, default: 1
    field :slug, :string
    # field :highlights, :string
    # field :short_name, :string
    # field :photo_locations, []

    many_to_many :programs, Counselling.Programs.Program, join_through: "college_programs"
    has_many :rank_cutoffs, Counselling.Ranks.RankCutoff
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
      :link_to_website,
      :campus_area
    ])
    |> validate_required([:name, :established_year, :location, :class])
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
    |> String.replace([" ", ","], "-")
  end
end
