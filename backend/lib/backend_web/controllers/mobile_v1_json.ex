defmodule BackendWeb.MobileV1JSON do
  @moduledoc "Stable child-safe JSON shapes for the future Flutter client."

  def session(session), do: %{data: session_data(session)}

  def answer(answer_result) do
    %{
      data: %{
        task_attempt: attempt_data(answer_result.task_attempt),
        feedback: feedback_data(answer_result.feedback),
        next_task: task_data(answer_result.session.next_task),
        progress_summary: answer_result.session.progress.summary
      }
    }
  end

  def diagnostic_started(%{session: session, task: task}) do
    %{
      data: %{
        session: %{id: session.id, child_id: session.child_profile_id, status: session.status},
        task: diagnostic_task_data(task)
      }
    }
  end

  def diagnostic_answer(diagnostic) do
    data = %{
      session: %{id: diagnostic.session.id, status: diagnostic.session.status},
      answer: %{
        task_id: diagnostic.answer.task_id,
        selected_answer: diagnostic.answer.selected_answer,
        is_correct: diagnostic.answer.is_correct,
        position: diagnostic.answer.position
      },
      completed: diagnostic.completed,
      next_task: diagnostic_task_data(diagnostic.next_task)
    }

    %{data: maybe_put_result(data, Map.get(diagnostic, :result))}
  end

  defp session_data(session) do
    %{
      child: %{id: session.child.id, name: session.child.name, age: session.child.age},
      next_task: task_data(session.next_task),
      progress_summary: session.progress.summary,
      recommendations_count: length(session.progress.recommendations),
      session_state: session.session_state
    }
  end

  defp task_data(nil), do: nil

  defp task_data(task) do
    %{
      id: task.id,
      skill_id: task.skill_id,
      skill_title: task.skill.title,
      area: task.skill.area,
      area_label: area_label(task.skill.area),
      type: task.type,
      question: task.question,
      options: task.options,
      difficulty: task.difficulty
    }
  end

  defp attempt_data(attempt) do
    %{
      id: attempt.id,
      task_id: attempt.task_id,
      selected_answer: attempt.selected_answer,
      is_correct: attempt.is_correct,
      attempt_number: attempt.attempt_number,
      hint_used: attempt.hint_used
    }
  end

  defp feedback_data(feedback) do
    %{
      result: feedback.result,
      action: feedback.action,
      message: feedback.message,
      hint: Map.get(feedback, :hint),
      explanation: Map.get(feedback, :explanation),
      can_continue: feedback.can_continue
    }
  end

  defp diagnostic_task_data(nil), do: nil

  defp diagnostic_task_data(%{area: area, task: task}) do
    %{
      id: task.id,
      skill_id: task.skill_id,
      area: area,
      area_label: area_label(area),
      type: task.type,
      question: task.question,
      options: task.options,
      difficulty: task.difficulty
    }
  end

  defp maybe_put_result(data, nil), do: data
  defp maybe_put_result(data, result), do: Map.put(data, :result, result)

  defp area_label("math"), do: "Счёт"
  defp area_label("reading"), do: "Чтение"
  defp area_label("logic"), do: "Логика"
  defp area_label(area), do: area
end
