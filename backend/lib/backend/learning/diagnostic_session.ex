defmodule Backend.Learning.DiagnosticSession do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Learning.ChildProfile

  schema "diagnostic_sessions" do
    field :status, :string, default: "in_progress"
    field :completed_at, :utc_datetime

    belongs_to :child_profile, ChildProfile

    timestamps(type: :utc_datetime)
  end

  def create_changeset(diagnostic_session, child_profile_id) do
    diagnostic_session
    |> change(child_profile_id: child_profile_id, status: "in_progress")
    |> validate_required([:child_profile_id, :status])
    |> foreign_key_constraint(:child_profile_id)
  end

  def complete_changeset(diagnostic_session) do
    diagnostic_session
    |> change(status: "completed", completed_at: DateTime.utc_now() |> DateTime.truncate(:second))
    |> validate_required([:status, :completed_at])
  end
end
