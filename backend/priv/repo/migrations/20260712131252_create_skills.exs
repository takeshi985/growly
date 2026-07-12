defmodule Backend.Repo.Migrations.CreateSkills do
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :title, :string
      add :area, :string
      add :age_min, :integer
      add :age_max, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
