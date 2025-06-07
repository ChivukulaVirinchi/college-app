defmodule Counselling.Repo.Migrations.CreateNirfRankings do
  use Ecto.Migration

  def change do
    create table(:nirf_rankings) do
      add :nirf_rank, :integer
      add :year, :integer
      add :college_id, references(:colleges, on_delete: :delete_all)

      timestamps()
    end

    create index(:nirf_rankings, [:college_id, :year])
    create index(:nirf_rankings, [:year, :nirf_rank])
  end
end
