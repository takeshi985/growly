defmodule Backend.Learning.TaskAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Task
  alias Backend.Learning.ChildProfile

  schema "task_attempts" do
    field :selected_answer, :string
    field :is_correct, :boolean, default: false
    field :hint_used, :boolean, default: false
    field :attempt_number, :integer

    belongs_to :child_profile, ChildProfile
    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_attempt, attrs) do
    task_attempt
    |> cast(attrs, [
      :child_profile_id,
      :task_id,
      :selected_answer,
      :is_correct,
      :hint_used,
      :attempt_number
    ])
    |> validate_required([
      :child_profile_id,
      :task_id,
      :selected_answer,
      :is_correct,
      :hint_used,
      :attempt_number
    ])
    |> validate_number(:attempt_number, greater_than_or_equal_to: 1)
    |> foreign_key_constraint(:child_profile_id)
    |> foreign_key_constraint(:task_id)
  end
end
