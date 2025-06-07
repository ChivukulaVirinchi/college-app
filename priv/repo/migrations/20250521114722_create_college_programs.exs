defmodule Counselling.Repo.Migrations.CreateCollegePrograms do
  use Ecto.Migration

  def change do
    create table(:college_programs) do
      add :college_id, references(:colleges, on_delete: :delete_all), null: false
      add :program_id, references(:programs, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:college_programs, [:college_id, :program_id])
    create index(:college_programs, [:program_id])
    create index(:college_programs, [:college_id])
  end
end
