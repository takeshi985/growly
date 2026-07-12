defmodule BackendWeb.ChildTaskAnswerJSON do
  alias Backend.Learning.TaskAttempt

  @doc """
  Renders an evaluated answer for the child application.
  """
  def show(%{answer_result: %{task_attempt: task_attempt, feedback: feedback}}) do
    %{
      data: %{
        attempt: attempt_data(task_attempt),
        feedback: feedback
      }
    }
  end

  defp attempt_data(%TaskAttempt{} = task_attempt) do
    %{
      id: task_attempt.id,
      task_id: task_attempt.task_id,
      selected_answer: task_attempt.selected_answer,
      is_correct: task_attempt.is_correct,
      hint_used: task_attempt.hint_used,
      attempt_number: task_attempt.attempt_number
    }
  end
end
