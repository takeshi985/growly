defmodule BackendWeb.ChildNextTaskJSON do
  alias Backend.Content.Task

  @doc """
  Renders the next task for a child.

  This response intentionally does not expose `correct_answer`; the app sends
  the selected answer back to the backend, and the backend grades it.
  """
  def show(%{task: task}) do
    %{data: data(task)}
  end

  defp data(%Task{} = task) do
    %{
      id: task.id,
      skill_id: task.skill_id,
      type: task.type,
      question: task.question,
      options: task.options,
      difficulty: task.difficulty,
      hint1: task.hint1,
      hint2: task.hint2,
      explanation: task.explanation
    }
  end
end
