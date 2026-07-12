defmodule Backend.Repo.Migrations.CreateTaskAttempts do
  use Ecto.Migration

  def change do
    create table(:task_attempts) do
      add :selected_answer, :string
      add :is_correct, :boolean, default: false, null: false
      add :hint_used, :boolean, default: false, null: false
      add :attempt_number, :integer
      add :child_profile_id, references(:child_profiles, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:task_attempts, [:child_profile_id])
    create index(:task_attempts, [:task_id])
  end
end
