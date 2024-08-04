defmodule Counselling.Repo.Migrations.CreatePrograms do
  use Ecto.Migration

  def change do
    create table(:programs) do
      add :name, :string, null: false
      add :duration, :integer, null: false
      add :branch_id, references(:branches, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:programs, [:branch_id])
  end
end
