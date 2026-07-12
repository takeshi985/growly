defmodule Backend.Repo.Migrations.CreateDiagnosticAnswers do
  use Ecto.Migration

  def change do
    create table(:diagnostic_answers) do
      add :selected_answer, :string, null: false
      add :is_correct, :boolean, null: false
      add :position, :integer, null: false

      add :diagnostic_session_id, references(:diagnostic_sessions, on_delete: :delete_all),
        null: false

      add :task_id, references(:tasks, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:diagnostic_answers, [:diagnostic_session_id])
    create unique_index(:diagnostic_answers, [:diagnostic_session_id, :task_id])
  end
end
