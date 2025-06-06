defmodule Counselling.Repo.Migrations.CreateColleges do
  use Ecto.Migration

  def change do
    create table(:colleges) do
      add :name, :string
      add :established_year, :integer
      add :location, :string
      add :class, :string
      add :website, :string
      add :campus_area, :integer
      add :slug, :string
      add :photo_path, :string
      add :description, :text

      timestamps()
    end

    create unique_index(:colleges, [:name])
  end
end
