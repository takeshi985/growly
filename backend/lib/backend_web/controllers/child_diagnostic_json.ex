defmodule BackendWeb.ChildDiagnosticJSON do
  @doc """
  Renders a new diagnostic session and its first task without exposing the
  correct answer to the child application.
  """
  def started(%{diagnostic: %{session: session, task: task}}) do
    %{
      data: %{
        session: session_data(session),
        task: task_data(task)
      }
    }
  end

  defp session_data(session) do
    %{id: session.id, child_profile_id: session.child_profile_id, status: session.status}
  end

  defp task_data(%{area: area, task: task}) do
    %{
      area: area,
      id: task.id,
      skill_id: task.skill_id,
      type: task.type,
      question: task.question,
      options: task.options,
      difficulty: task.difficulty,
      hint1: task.hint1,
      hint2: task.hint2
    }
  end
end
