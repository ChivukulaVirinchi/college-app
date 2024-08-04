defmodule Counselling.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :duration, :integer, null: false
      add :degree_type, :string, null: false
      timestamps()
    end

    create unique_index(:programs, [:name, :duration, :degree_type])
  end
end
