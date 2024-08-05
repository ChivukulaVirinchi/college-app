defmodule Counselling.Repo.Migrations.AddSlugToColleges do
  use Ecto.Migration

  def change do
    alter table(:colleges) do
      add :slug, :string
    end
  end
end
