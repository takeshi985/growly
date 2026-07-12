defmodule Backend.Repo.Migrations.CreateChildProfiles do
  use Ecto.Migration

  def change do
    create table(:child_profiles) do
      add :name, :string
      add :age, :integer
      add :parent_id, references(:parents, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:child_profiles, [:parent_id])
  end
end
