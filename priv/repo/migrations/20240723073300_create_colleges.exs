defmodule Counselling.Repo.Migrations.CreateColleges do
  use Ecto.Migration

  def change do
    create table(:colleges) do
      add :name, :string
      add :established_year, :integer
      add :location, :string

      timestamps(type: :utc_datetime)
    end
  end
end
