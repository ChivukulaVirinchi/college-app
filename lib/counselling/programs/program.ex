defmodule Counselling.Programs.Program do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Counselling.Colleges.Permalink, autogenerate: true}
  schema "programs" do
    field :name, :string
    field :duration, :integer
    field :degree_type, :string
    field :slug, :string
    # program description
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
    |> String.replace(" ", "-")
  end
end
