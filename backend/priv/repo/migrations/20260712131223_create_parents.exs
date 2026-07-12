defmodule Backend.Repo.Migrations.CreateParents do
  use Ecto.Migration

  def change do
    create table(:parents) do
      add :email, :string

      timestamps(type: :utc_datetime)
    end
  end
end
