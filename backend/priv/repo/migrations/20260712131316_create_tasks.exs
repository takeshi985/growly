defmodule Backend.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :type, :string
      add :question, :string
      add :options, :map
      add :correct_answer, :string
      add :difficulty, :integer
      add :hint1, :string
      add :hint2, :string
      add :explanation, :string
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:skill_id])
  end
end
