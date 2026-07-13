defmodule BackendWeb.MobileV1JSON do
  @moduledoc "Stable child-safe JSON shapes for the future Flutter client."

  def health do
    %{data: %{status: "ok", service: "growly", version: "mobile-v1"}}
  end

  def demo_bootstrap(demo) do
    child_id = demo.child.id

    %{
      data: %{
        parent: %{id: demo.parent.id, email: demo.parent.email},
        child: %{id: child_id, name: demo.child.name, age: demo.child.age},
        links: %{
          session: "/api/mobile/v1/children/#{child_id}/session",
          progress: "/api/mobile/v1/children/#{child_id}/progress",
          lesson_map: "/api/mobile/v1/children/#{child_id}/lesson_map"
        }
      }
    }
  end

  def pairing_session(%{child: child, pairing: pairing}) do
    %{
      data: %{
        child: %{id: child.id, name: child.name, age: child.age},
        pairing: %{
          code: pairing.code,
          token: pairing.token,
          expires_at: pairing.expires_at,
          qr_payload: "growly://pair?token=#{pairing.token}"
        }
      }
    }
  end

  def pairing_claim(%{child: child}) do
    child_id = child.id

    %{
      data: %{
        child: %{id: child_id, name: child.name, age: child.age},
        links: %{
          progress: "/api/mobile/v1/children/#{child_id}/progress",
          lesson_map: "/api/mobile/v1/children/#{child_id}/lesson_map"
        }
      }
    }
  end

  def session(session), do: %{data: session_data(session)}

  def catalog(courses) do
    %{data: %{courses: Enum.map(courses, &catalog_course/1)}}
  end

  def course(course),
    do: %{data: %{course: course_data(course), units: Enum.map(course.units, &unit_data/1)}}

  def course_map(course), do: course(course)

  def lesson(lesson) do
    %{
      data: %{
        lesson: lesson_data(lesson),
        unit: %{id: lesson.unit.id, title: lesson.unit.title, area: lesson.unit.area},
        course: %{
          id: lesson.unit.course.id,
          title: lesson.unit.course.title,
          slug: lesson.unit.course.slug
        },
        tasks: Enum.map(Enum.sort_by(lesson.tasks, &{&1.position, &1.id}), &lesson_task_data/1)
      }
    }
  end

  def lesson_map(map) do
    %{
      data: %{
        child: map.child,
        course: course_data(map.course),
        units: map.units
      }
    }
  end

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

  defp catalog_course(course) do
    %{
      id: course.id,
      title: course.title,
      slug: course.slug,
      description: course.description,
      age_min: course.age_min,
      age_max: course.age_max,
      units_count: length(course.units),
      lessons_count: Enum.sum_by(course.units, &length(&1.lessons))
    }
  end

  defp course_data(course) do
    Map.take(course, [:id, :title, :slug, :description, :age_min, :age_max, :sort_order])
  end

  defp unit_data(unit) do
    %{
      id: unit.id,
      title: unit.title,
      slug: unit.slug,
      description: unit.description,
      area: unit.area,
      area_label: area_label(unit.area),
      sort_order: unit.sort_order,
      lessons: Enum.map(unit.lessons, &lesson_data/1)
    }
  end

  defp lesson_data(lesson) do
    %{
      id: lesson.id,
      title: lesson.title,
      slug: lesson.slug,
      objective: lesson.objective,
      explanation: lesson.explanation,
      skill_id: lesson.skill_id,
      sort_order: lesson.sort_order,
      is_published: lesson.is_published,
      tasks_count: length(lesson.tasks)
    }
  end

  defp lesson_task_data(task) do
    %{
      id: task.id,
      skill_id: task.skill_id,
      lesson_id: task.lesson_id,
      type: task.type,
      question: task.question,
      options: task.options,
      difficulty: task.difficulty,
      position: task.position
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
