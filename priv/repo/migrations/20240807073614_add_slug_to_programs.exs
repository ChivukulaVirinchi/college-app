defmodule Counselling.Repo.Migrations.AddSlugToPrograms do
  use Ecto.Migration

  def change do
    alter table(:programs) do
      add :slug, :string
    end
  end
end
