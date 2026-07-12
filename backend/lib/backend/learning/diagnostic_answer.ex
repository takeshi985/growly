defmodule Backend.Learning.DiagnosticAnswer do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Task
  alias Backend.Learning.DiagnosticSession

  schema "diagnostic_answers" do
    field :selected_answer, :string
    field :is_correct, :boolean
    field :position, :integer

    belongs_to :diagnostic_session, DiagnosticSession
    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  def changeset(diagnostic_answer, attrs, diagnostic_session_id, task_id, is_correct, position) do
    diagnostic_answer
    |> cast(attrs, [:selected_answer])
    |> put_change(:diagnostic_session_id, diagnostic_session_id)
    |> put_change(:task_id, task_id)
    |> put_change(:is_correct, is_correct)
    |> put_change(:position, position)
    |> validate_required([
      :selected_answer,
      :diagnostic_session_id,
      :task_id,
      :is_correct,
      :position
    ])
    |> validate_number(:position, greater_than_or_equal_to: 1)
    |> foreign_key_constraint(:diagnostic_session_id)
    |> foreign_key_constraint(:task_id)
    |> unique_constraint([:diagnostic_session_id, :task_id])
  end
end
