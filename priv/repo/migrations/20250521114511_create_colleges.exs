defmodule Counselling.Repo.Migrations.CreateColleges do
  use Ecto.Migration

  def change do
    create table(:colleges) do
      add :name, :string
      add :established_year, :integer
      add :location, :string
      add :class, :string
      add :link_to_website, :string
      add :campus_area, :integer
      add :slug, :string
      timestamps()
    end

    create unique_index(:colleges, [:name])
  end
end
