defmodule Counselling.Repo.Migrations.CreateBranches do
  use Ecto.Migration

  def change do
    create table(:branches) do
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:branches, [:name])
  end
end
