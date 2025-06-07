defmodule Counselling.Repo.Migrations.CreateRankCutoffs do
  use Ecto.Migration

  def change do
    create table(:rank_cutoffs) do
      add :opening_rank, :integer, null: false
      add :closing_rank, :integer, null: false
      add :quota, :string, null: false
      add :category, :string, null: false
      add :year, :integer, null: false

      add :college_program_id, references(:college_programs, on_delete: :restrict)
      timestamps()
    end

    create index(:rank_cutoffs, [:year, :category, :quota, :college_program_id])
    create index(:rank_cutoffs, [:college_program_id, :closing_rank])
  end
end
