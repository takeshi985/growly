defmodule Backend.Repo.Migrations.AddPairingSessions do
  use Ecto.Migration

  def change do
    create table(:pairing_sessions) do
      add :child_profile_id, references(:child_profiles, on_delete: :delete_all), null: false
      add :code, :string, null: false
      add :token, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :claimed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:pairing_sessions, [:code])
    create unique_index(:pairing_sessions, [:token])
    create index(:pairing_sessions, [:child_profile_id])
    create index(:pairing_sessions, [:expires_at])

    create constraint(:pairing_sessions, :pairing_sessions_code_format,
             check: "code ~ '^[0-9]{8}$'"
           )
  end
end
