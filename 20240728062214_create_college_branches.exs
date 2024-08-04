defmodule Counselling.Repo.Migrations.CreateCollegeBranches do
  use Ecto.Migration

  def change do
    create table(:college_branches) do
      add :college_id, references(:colleges, on_delete: :delete_all), null: false
      add :branch_id, references(:branches, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:college_branches, [:college_id])
    create index(:college_branches, [:branch_id])
    create unique_index(:college_branches, [:college_id, :branch_id])
  end
end
