defmodule Backend.Repo.Migrations.CreateDiagnosticSessions do
  use Ecto.Migration

  def change do
    create table(:diagnostic_sessions) do
      add :status, :string, null: false, default: "in_progress"
      add :completed_at, :utc_datetime
      add :child_profile_id, references(:child_profiles, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:diagnostic_sessions, [:child_profile_id])
  end
end
