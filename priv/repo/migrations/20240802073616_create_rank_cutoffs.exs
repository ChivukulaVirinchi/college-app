defmodule Counselling.Repo.Migrations.CreateRankCutoffs do
  use Ecto.Migration

  def change do
    create table(:rank_cutoffs) do
      add :opening_rank, :integer, null: false
      add :closing_rank, :integer, null: false
      add :quota, :string, null: false
      add :category, :string, null: false

      add :college_id, references(:colleges, on_delete: :delete_all), null: false
      add :program_id, references(:programs, on_delete: :delete_all), null: false

      # add :college_program_id,
      #     references(:college_programs, on_delete: :delete_all),
      #     null: false

      add :year, :integer, null: false
      timestamps()
    end

    # create index(:rank_cutoffs, [:college_program_id])
    create unique_index(:rank_cutoffs, [:year, :college_id, :program_id, :quota, :category])
  end
end
