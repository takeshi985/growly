defmodule Backend.Repo.Migrations.AddCurriculumAndWorkbooks do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false
      add :age_min, :integer, null: false
      add :age_max, :integer, null: false
      add :is_published, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create unique_index(:courses, [:slug])

    create table(:units) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false
      add :area, :string, null: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create index(:units, [:course_id])
    create unique_index(:units, [:course_id, :slug])

    create table(:lessons) do
      add :unit_id, references(:units, on_delete: :delete_all), null: false
      add :skill_id, references(:skills, on_delete: :nilify_all)
      add :title, :string, null: false
      add :slug, :string, null: false
      add :objective, :text, null: false
      add :explanation, :text, null: false
      add :sort_order, :integer, null: false, default: 0
      add :is_published, :boolean, null: false, default: false
      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:unit_id])
    create index(:lessons, [:skill_id])
    create unique_index(:lessons, [:unit_id, :slug])

    alter table(:tasks) do
      add :lesson_id, references(:lessons, on_delete: :nilify_all)
      add :position, :integer, null: false, default: 0
    end

    create index(:tasks, [:lesson_id])

    create table(:workbooks) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :description, :text, null: false
      add :age_min, :integer, null: false
      add :age_max, :integer, null: false
      add :is_published, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      timestamps(type: :utc_datetime)
    end

    create unique_index(:workbooks, [:slug])

    create table(:workbook_pages) do
      add :workbook_id, references(:workbooks, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, on_delete: :nilify_all)
      add :title, :string, null: false
      add :page_number, :integer, null: false
      add :instructions, :text, null: false
      add :qr_code_token, :string, null: false
      add :qr_target_type, :string, null: false
      add :qr_target_id, :integer
      add :is_published, :boolean, null: false, default: false
      timestamps(type: :utc_datetime)
    end

    create index(:workbook_pages, [:workbook_id])
    create index(:workbook_pages, [:lesson_id])
    create unique_index(:workbook_pages, [:qr_code_token])
    create unique_index(:workbook_pages, [:workbook_id, :page_number])
  end
end
