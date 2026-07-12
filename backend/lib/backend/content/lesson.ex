defmodule Backend.Content.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Skill
  alias Backend.Content.Task
  alias Backend.Content.Unit

  schema "lessons" do
    field :title, :string
    field :slug, :string
    field :objective, :string
    field :explanation, :string
    field :sort_order, :integer, default: 0
    field :is_published, :boolean, default: false
    belongs_to :unit, Unit
    belongs_to :skill, Skill
    has_many :tasks, Task
    timestamps(type: :utc_datetime)
  end

  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [
      :unit_id,
      :skill_id,
      :title,
      :slug,
      :objective,
      :explanation,
      :sort_order,
      :is_published
    ])
    |> validate_required([
      :unit_id,
      :title,
      :slug,
      :objective,
      :explanation,
      :sort_order,
      :is_published
    ])
    |> validate_number(:sort_order, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:unit_id)
    |> foreign_key_constraint(:skill_id)
    |> unique_constraint([:unit_id, :slug])
  end
end
