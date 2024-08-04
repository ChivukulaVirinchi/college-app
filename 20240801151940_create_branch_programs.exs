defmodule Counselling.Repo.Migrations.CreateBranchPrograms do
  use Ecto.Migration

  def change do
    create table(:branch_programs) do
      add :college_id, references(:colleges, on_delete: :delete_all), null: false
      add :program_id, references(:programs, on_delete: :delete_all), null: false
      add :branch_id, references(:branches, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:branch_programs, [:college_id])
    create index(:branch_programs, [:program_id])
    create index(:branch_programs, [:branch_id])
    create unique_index(:branch_programs, [:college_id, :program_id, :branch_id])
  end
end
