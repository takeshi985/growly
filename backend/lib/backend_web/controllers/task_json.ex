defmodule BackendWeb.TaskJSON do
  alias Backend.Content.Task

  @doc """
  Renders a list of tasks.
  """
  def index(%{tasks: tasks}) do
    %{data: for(task <- tasks, do: data(task))}
  end

  @doc """
  Renders a single task.
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
      correct_answer: task.correct_answer,
      difficulty: task.difficulty,
      hint1: task.hint1,
      hint2: task.hint2,
      explanation: task.explanation
    }
  end
end
