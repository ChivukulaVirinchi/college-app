defmodule Counselling.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :duration, :integer, null: false
      add :degree_type, :string, null: false

      add :slug, :string
      timestamps()
    end

    create unique_index(:programs, [:name, :duration, :degree_type])
    create index(:programs, [:name])
    create index(:programs, [:degree_type])
    create index(:programs, [:name, :degree_type])
  end
end
