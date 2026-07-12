defmodule Backend.Content.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Lesson
  alias Backend.Content.Skill

  schema "tasks" do
    field(:type, :string)
    field(:question, :string)
    field(:options, :map)
    field(:correct_answer, :string)
    field(:difficulty, :integer)
    field(:hint1, :string)
    field(:hint2, :string)
    field(:explanation, :string)
    field(:options_text, :string, virtual: true)
    field(:position, :integer, default: 0)

    belongs_to(:skill, Skill)
    belongs_to(:lesson, Lesson)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :type,
      :question,
      :options,
      :correct_answer,
      :difficulty,
      :hint1,
      :hint2,
      :explanation,
      :options_text,
      :lesson_id,
      :position,
      :skill_id
    ])
    |> validate_required([
      :type,
      :question,
      :options,
      :correct_answer,
      :difficulty,
      :hint1,
      :hint2,
      :explanation,
      :skill_id
    ])
    |> validate_number(:difficulty, greater_than_or_equal_to: 1)
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:skill_id)
    |> foreign_key_constraint(:lesson_id)
  end
end
