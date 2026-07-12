defmodule BackendWeb.TaskAttemptJSON do
  alias Backend.Learning.TaskAttempt

  @doc """
  Renders a list of task_attempts.
  """
  def index(%{task_attempts: task_attempts}) do
    %{data: for(task_attempt <- task_attempts, do: data(task_attempt))}
  end

  @doc """
  Renders a single task_attempt.
  """
  def show(%{task_attempt: task_attempt}) do
    %{data: data(task_attempt)}
  end

  defp data(%TaskAttempt{} = task_attempt) do
    %{
      id: task_attempt.id,
      child_profile_id: task_attempt.child_profile_id,
      task_id: task_attempt.task_id,
      selected_answer: task_attempt.selected_answer,
      is_correct: task_attempt.is_correct,
      hint_used: task_attempt.hint_used,
      attempt_number: task_attempt.attempt_number
    }
  end
end
