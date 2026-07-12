defmodule BackendWeb.DiagnosticAnswerJSON do
  @doc """
  Renders the result of a diagnostic answer.
  """
  def show(%{diagnostic: diagnostic}) do
    %{
      data:
        %{
          session: session_data(diagnostic.session),
          answer: answer_data(diagnostic.answer),
          completed: diagnostic.completed,
          next_task: next_task_data(diagnostic.next_task)
        }
        |> maybe_put_result(Map.get(diagnostic, :result))
    }
  end

  defp session_data(session), do: %{id: session.id, status: session.status}

  defp answer_data(answer) do
    %{
      task_id: answer.task_id,
      selected_answer: answer.selected_answer,
      is_correct: answer.is_correct,
      position: answer.position
    }
  end

  defp next_task_data(nil), do: nil

  defp next_task_data(%{area: area, task: task}) do
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

  defp maybe_put_result(data, nil), do: data
  defp maybe_put_result(data, result), do: Map.put(data, :result, result)
end
