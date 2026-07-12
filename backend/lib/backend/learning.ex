defmodule Backend.Learning do
  @moduledoc """
  The Learning context.

  This context is responsible for child profiles and task attempts.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset

  alias Backend.Repo
  alias Backend.Content.Skill
  alias Backend.Content.Task
  alias Backend.Learning.ChildProfile
  alias Backend.Learning.DiagnosticAnswer
  alias Backend.Learning.DiagnosticSession
  alias Backend.Learning.TaskAttempt

  @diagnostic_areas ["math", "reading", "logic"]

  # ---------------------------------------------------------------------------
  # Child profiles
  # ---------------------------------------------------------------------------

  @doc """
  Returns the list of child_profiles.
  """
  def list_child_profiles do
    Repo.all(ChildProfile)
  end

  @doc """
  Gets a single child_profile.

  Raises `Ecto.NoResultsError` if the child profile does not exist.
  """
  def get_child_profile!(id), do: Repo.get!(ChildProfile, id)

  @doc """
  Creates a child_profile.
  """
  def create_child_profile(attrs \\ %{}) do
    %ChildProfile{}
    |> ChildProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a child_profile.
  """
  def update_child_profile(%ChildProfile{} = child_profile, attrs) do
    child_profile
    |> ChildProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a child_profile.
  """
  def delete_child_profile(%ChildProfile{} = child_profile) do
    Repo.delete(child_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking child_profile changes.
  """
  def change_child_profile(%ChildProfile{} = child_profile, attrs \\ %{}) do
    ChildProfile.changeset(child_profile, attrs)
  end

  @doc """
  Returns the next suitable task for a child.

  For the first backend version we keep the rule intentionally simple:

  * the task's skill must match the child's age;
  * tasks already answered correctly by this child are skipped;
  * lower difficulty tasks come first.
  """
  def next_task_for_child(child_profile_id) do
    case Repo.get(ChildProfile, child_profile_id) do
      nil ->
        {:error, :child_profile_not_found}

      %ChildProfile{} = child_profile ->
        completed_task_ids =
          from(task_attempt in TaskAttempt,
            where:
              task_attempt.child_profile_id == ^child_profile.id and
                task_attempt.is_correct == true,
            select: task_attempt.task_id
          )

        deferred_task_ids =
          from(task_attempt in TaskAttempt,
            where:
              task_attempt.child_profile_id == ^child_profile.id and
                task_attempt.is_correct == false,
            group_by: task_attempt.task_id,
            having: count(task_attempt.id) >= 3,
            select: task_attempt.task_id
          )

        candidates =
          from(task in Task,
            join: skill in Skill,
            on: skill.id == task.skill_id,
            where:
              skill.age_min <= ^child_profile.age and
                skill.age_max >= ^child_profile.age and
                task.id not in subquery(completed_task_ids) and
                task.id not in subquery(deferred_task_ids),
            order_by: [asc: task.difficulty, asc: task.id],
            select: {task, skill.area}
          )
          |> Repo.all()

        task = choose_session_task(candidates, child_profile.id)

        case task do
          nil -> {:error, :no_task_available}
          %Task{} = task -> {:ok, task}
        end
    end
  end

  defp choose_session_task([], _child_profile_id), do: nil

  defp choose_session_task(candidates, child_profile_id) do
    latest_attempt =
      from(attempt in TaskAttempt,
        join: task in Task,
        on: task.id == attempt.task_id,
        join: skill in Skill,
        on: skill.id == task.skill_id,
        where: attempt.child_profile_id == ^child_profile_id,
        order_by: [desc: attempt.id],
        limit: 1,
        select: %{task_id: attempt.task_id, area: skill.area, is_correct: attempt.is_correct}
      )
      |> Repo.one()

    retry_task =
      if latest_attempt && not latest_attempt.is_correct do
        Enum.find(candidates, fn {task, _area} -> task.id == latest_attempt.task_id end)
      end

    case retry_task do
      {task, _area} ->
        task

      nil ->
        minimum_difficulty = candidates |> List.first() |> elem(0) |> Map.fetch!(:difficulty)

        easiest =
          Enum.take_while(candidates, fn {task, _area} ->
            task.difficulty == minimum_difficulty
          end)

        preferred =
          if latest_attempt do
            Enum.find(easiest, fn {_task, area} -> area != latest_attempt.area end)
          end

        {task, _area} = preferred || List.first(easiest)
        task
    end
  end

  @doc """
  Builds the stable learning-session state consumed by mobile and browser clients.

  The task is returned with its skill preloaded, while answer keys and staged
  hints remain server-side concerns handled by serializers and feedback.
  """
  def learning_session_for_child(child_profile_id) do
    with {:ok, child_profile} <- fetch_child_profile(child_profile_id),
         {:ok, progress} <- progress_for_child(child_profile.id) do
      case next_task_for_child(child_profile.id) do
        {:ok, task} ->
          {:ok,
           %{
             child: child_profile,
             next_task: Repo.preload(task, :skill),
             progress: progress,
             session_state: %{
               has_next_task: true,
               message: "Следующее короткое задание готово."
             }
           }}

        {:error, :no_task_available} ->
          {:ok,
           %{
             child: child_profile,
             next_task: nil,
             progress: progress,
             session_state: %{
               has_next_task: false,
               message: "Все доступные задания пройдены. Можно отдохнуть или вернуться позже."
             }
           }}
      end
    end
  end

  @doc """
  Returns a parent-friendly progress report for a child.

  Progress is calculated from recorded task attempts instead of being stored as
  a separate value. This keeps the report consistent when educational content
  or a child's answers change.
  """
  def progress_for_child(child_profile_id) do
    case Repo.get(ChildProfile, child_profile_id) do
      nil ->
        {:error, :child_profile_not_found}

      %ChildProfile{} = child_profile ->
        skills = age_appropriate_skills(child_profile.age)
        skill_ids = Enum.map(skills, & &1.id)
        tasks_by_skill = tasks_by_skill(skill_ids)
        attempts_by_skill = attempts_by_skill(child_profile.id, skill_ids)

        skills_progress =
          Enum.map(skills, fn skill ->
            build_skill_progress(
              skill,
              Map.get(tasks_by_skill, skill.id, []),
              Map.get(attempts_by_skill, skill.id, [])
            )
          end)

        {:ok,
         %{
           child: %{id: child_profile.id, name: child_profile.name, age: child_profile.age},
           summary: build_progress_summary(skills_progress),
           skills: skills_progress,
           recommendations: build_recommendations(skills_progress)
         }}
    end
  end

  # ---------------------------------------------------------------------------
  # Initial diagnostic
  # ---------------------------------------------------------------------------

  @doc """
  Starts a short diagnostic session for a child.

  The first version includes one age-appropriate, introductory task from each
  available core area: math, reading, and logic.
  """
  def start_diagnostic(child_profile_id) do
    with {:ok, child_profile} <- fetch_child_profile(child_profile_id) do
      case diagnostic_tasks_for_child(child_profile) do
        [] ->
          {:error, :no_diagnostic_tasks_available}

        [first_task | _remaining_tasks] ->
          %DiagnosticSession{}
          |> DiagnosticSession.create_changeset(child_profile.id)
          |> Repo.insert()
          |> case do
            {:ok, diagnostic_session} ->
              {:ok, %{session: diagnostic_session, task: first_task}}

            {:error, changeset} ->
              {:error, changeset}
          end
      end
    end
  end

  @doc """
  Grades one answer in a diagnostic session and returns the next task or the
  completed diagnostic result.
  """
  def submit_diagnostic_answer(diagnostic_session_id, task_id, attrs \\ %{}) do
    attrs = stringify_keys(attrs)

    with {:ok, diagnostic_session} <- fetch_diagnostic_session(diagnostic_session_id),
         :ok <- ensure_diagnostic_in_progress(diagnostic_session),
         {:ok, expected_task} <- next_diagnostic_task(diagnostic_session),
         :ok <- ensure_expected_diagnostic_task(expected_task, task_id),
         {:ok, diagnostic_answer} <-
           create_diagnostic_answer(diagnostic_session, expected_task.task, attrs) do
      case next_diagnostic_task(diagnostic_session) do
        {:ok, next_task} ->
          {:ok,
           %{
             session: diagnostic_session,
             answer: diagnostic_answer,
             next_task: next_task,
             completed: false
           }}

        {:error, :diagnostic_complete} ->
          {:ok, completed_session} =
            diagnostic_session
            |> DiagnosticSession.complete_changeset()
            |> Repo.update()

          {:ok,
           %{
             session: completed_session,
             answer: diagnostic_answer,
             next_task: nil,
             completed: true,
             result: diagnostic_result(completed_session.id)
           }}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Task attempts
  # ---------------------------------------------------------------------------

  @doc """
  Returns the list of task_attempts.
  """
  def list_task_attempts do
    Repo.all(TaskAttempt)
  end

  @doc """
  Gets a single task_attempt.

  Raises `Ecto.NoResultsError` if the task attempt does not exist.
  """
  def get_task_attempt!(id), do: Repo.get!(TaskAttempt, id)

  @doc """
  Creates a task_attempt.

  Important:
  The mobile app must not decide whether the answer is correct.
  It sends only selected_answer, and the backend compares it with the task's
  correct_answer.
  """
  def create_task_attempt(attrs \\ %{}) do
    attrs = stringify_keys(attrs)

    with {:ok, task} <- fetch_task(attrs["task_id"]) do
      selected_answer = attrs["selected_answer"]
      child_profile_id = attrs["child_profile_id"]
      task_id = attrs["task_id"]

      is_correct = selected_answer == task.correct_answer
      attempt_number = next_attempt_number(child_profile_id, task_id)

      attrs =
        attrs
        |> Map.put("is_correct", is_correct)
        |> Map.put("attempt_number", attempt_number)
        |> Map.put_new("hint_used", false)

      %TaskAttempt{}
      |> TaskAttempt.changeset(attrs)
      |> Repo.insert()
    else
      {:error, :task_not_found} ->
        changeset =
          %TaskAttempt{}
          |> TaskAttempt.changeset(attrs)
          |> Changeset.add_error(:task_id, "does not exist")

        {:error, changeset}
    end
  end

  @doc """
  Saves a child's answer and returns child-friendly feedback.

  The feedback follows Growly's anti-frustration rule:

  * a correct answer lets the child continue;
  * the first and second wrong answers reveal progressively stronger hints;
  * after the third wrong answer, the task is deferred for later practice.
  """
  def submit_task_answer(child_profile_id, task_id, attrs \\ %{}) do
    attrs = stringify_keys(attrs)

    with {:ok, child_profile} <- fetch_child_profile(child_profile_id),
         {:ok, task} <- fetch_task(task_id),
         {:ok, task_attempt} <-
           create_task_attempt(%{
             "child_profile_id" => child_profile.id,
             "task_id" => task.id,
             "selected_answer" => attrs["selected_answer"],
             "hint_used" => Map.get(attrs, "hint_used", false)
           }) do
      {:ok, %{task_attempt: task_attempt, feedback: feedback_for(task_attempt, task)}}
    end
  end

  @doc "Saves an answer and returns the refreshed mobile learning-session state."
  def submit_mobile_task_answer(child_profile_id, task_id, attrs \\ %{}) do
    with {:ok, answer_result} <- submit_task_answer(child_profile_id, task_id, attrs),
         {:ok, session} <- learning_session_for_child(child_profile_id) do
      {:ok, Map.merge(answer_result, %{session: session})}
    end
  end

  @doc """
  Updates a task_attempt.
  """
  def update_task_attempt(%TaskAttempt{} = task_attempt, attrs) do
    task_attempt
    |> TaskAttempt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task_attempt.
  """
  def delete_task_attempt(%TaskAttempt{} = task_attempt) do
    Repo.delete(task_attempt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task_attempt changes.
  """
  def change_task_attempt(%TaskAttempt{} = task_attempt, attrs \\ %{}) do
    TaskAttempt.changeset(task_attempt, attrs)
  end

  defp fetch_task(nil), do: {:error, :task_not_found}

  defp fetch_task(task_id) do
    case Repo.get(Task, task_id) do
      nil -> {:error, :task_not_found}
      task -> {:ok, task}
    end
  end

  defp fetch_child_profile(child_profile_id) do
    case Repo.get(ChildProfile, child_profile_id) do
      nil -> {:error, :child_profile_not_found}
      child_profile -> {:ok, child_profile}
    end
  end

  defp fetch_diagnostic_session(diagnostic_session_id) do
    case Repo.get(DiagnosticSession, diagnostic_session_id) do
      nil -> {:error, :diagnostic_session_not_found}
      diagnostic_session -> {:ok, diagnostic_session}
    end
  end

  defp ensure_diagnostic_in_progress(%DiagnosticSession{status: "in_progress"}), do: :ok
  defp ensure_diagnostic_in_progress(%DiagnosticSession{}), do: {:error, :diagnostic_completed}

  defp ensure_expected_diagnostic_task(%{task: task}, task_id) do
    if to_string(task.id) == to_string(task_id) do
      :ok
    else
      {:error, :unexpected_diagnostic_task}
    end
  end

  defp create_diagnostic_answer(diagnostic_session, task, attrs) do
    is_correct = attrs["selected_answer"] == task.correct_answer
    position = next_diagnostic_answer_position(diagnostic_session.id)

    %DiagnosticAnswer{}
    |> DiagnosticAnswer.changeset(
      attrs,
      diagnostic_session.id,
      task.id,
      is_correct,
      position
    )
    |> Repo.insert()
  end

  defp next_diagnostic_task(%DiagnosticSession{} = diagnostic_session) do
    with {:ok, child_profile} <- fetch_child_profile(diagnostic_session.child_profile_id) do
      answered_task_ids =
        from(diagnostic_answer in DiagnosticAnswer,
          where: diagnostic_answer.diagnostic_session_id == ^diagnostic_session.id,
          select: diagnostic_answer.task_id
        )
        |> Repo.all()
        |> MapSet.new()

      case Enum.find(diagnostic_tasks_for_child(child_profile), fn %{task: task} ->
             task.id not in answered_task_ids
           end) do
        nil -> {:error, :diagnostic_complete}
        task -> {:ok, task}
      end
    end
  end

  defp diagnostic_tasks_for_child(child_profile) do
    tasks_by_area =
      from(task in Task,
        join: skill in Skill,
        on: skill.id == task.skill_id,
        where: skill.age_min <= ^child_profile.age and skill.age_max >= ^child_profile.age,
        order_by: [asc: task.difficulty, asc: task.id],
        select: {skill.area, task}
      )
      |> Repo.all()
      |> Enum.group_by(fn {area, _task} -> area end, fn {_area, task} -> task end)

    diagnostic_areas =
      @diagnostic_areas ++
        (tasks_by_area
         |> Map.keys()
         |> Enum.reject(&(&1 in @diagnostic_areas))
         |> Enum.sort())

    Enum.flat_map(diagnostic_areas, fn area ->
      case Map.get(tasks_by_area, area, []) do
        [task | _remaining_tasks] -> [%{area: area, task: task}]
        [] -> []
      end
    end)
  end

  defp next_diagnostic_answer_position(diagnostic_session_id) do
    from(diagnostic_answer in DiagnosticAnswer,
      where: diagnostic_answer.diagnostic_session_id == ^diagnostic_session_id,
      select: count(diagnostic_answer.id)
    )
    |> Repo.one()
    |> Kernel.+(1)
  end

  defp diagnostic_result(diagnostic_session_id) do
    diagnostic_session = Repo.get!(DiagnosticSession, diagnostic_session_id)
    child = Repo.get!(ChildProfile, diagnostic_session.child_profile_id)

    areas =
      from(diagnostic_answer in DiagnosticAnswer,
        join: task in Task,
        on: task.id == diagnostic_answer.task_id,
        join: skill in Skill,
        on: skill.id == task.skill_id,
        where: diagnostic_answer.diagnostic_session_id == ^diagnostic_session_id,
        order_by: [asc: diagnostic_answer.position],
        select: %{
          area: skill.area,
          skill_id: skill.id,
          skill_title: skill.title,
          is_correct: diagnostic_answer.is_correct
        }
      )
      |> Repo.all()
      |> Enum.map(&diagnostic_area_result/1)

    recommended_focus = Enum.filter(areas, &(&1.result == :start_from_basics))
    recommended_area = List.first(recommended_focus)

    %{
      child: %{id: child.id, name: child.name, age: child.age},
      total_areas: length(areas),
      confident_areas: Enum.count(areas, &(&1.result == :ready_to_continue)),
      areas_needing_basics: length(recommended_focus),
      areas: areas,
      recommended_focus: recommended_focus,
      recommended_starting_area: recommended_area && recommended_area.area,
      recommended_starting_skill_id: recommended_area && recommended_area.skill_id,
      recommended_message: diagnostic_recommendation_message(recommended_area)
    }
  end

  defp diagnostic_area_result(%{is_correct: true} = area) do
    Map.merge(area, %{
      area_label: area_label(area.area),
      result: :ready_to_continue,
      message: "Можно продолжать с заданиями текущего уровня."
    })
  end

  defp diagnostic_area_result(area) do
    Map.merge(area, %{
      area_label: area_label(area.area),
      result: :start_from_basics,
      message: "Рекомендуем начать с базовых заданий и двигаться маленькими шагами."
    })
  end

  defp feedback_for(%TaskAttempt{is_correct: true}, _task) do
    %{
      result: :correct,
      action: :continue,
      message: "Отлично! Ты справился.",
      can_continue: true
    }
  end

  defp feedback_for(%TaskAttempt{attempt_number: 1}, %Task{} = task) do
    %{
      result: :incorrect,
      action: :show_hint1,
      message: "Почти! Давай посмотрим вместе.",
      hint: task.hint1,
      can_continue: true
    }
  end

  defp feedback_for(%TaskAttempt{attempt_number: 2}, %Task{} = task) do
    %{
      result: :incorrect,
      action: :show_hint2,
      message: "Ты хорошо стараешься. Вот ещё подсказка.",
      hint: task.hint2,
      can_continue: true
    }
  end

  defp feedback_for(%TaskAttempt{}, %Task{} = task) do
    %{
      result: :incorrect,
      action: :review_later,
      message: "Это задание пока сложное. Мы вернёмся к нему позже.",
      explanation: task.explanation,
      can_continue: true
    }
  end

  defp age_appropriate_skills(age) do
    from(skill in Skill,
      where: skill.age_min <= ^age and skill.age_max >= ^age,
      order_by: [asc: skill.area, asc: skill.id]
    )
    |> Repo.all()
  end

  defp tasks_by_skill([]), do: %{}

  defp tasks_by_skill(skill_ids) do
    from(task in Task, where: task.skill_id in ^skill_ids)
    |> Repo.all()
    |> Enum.group_by(& &1.skill_id)
  end

  defp attempts_by_skill(_child_profile_id, []), do: %{}

  defp attempts_by_skill(child_profile_id, skill_ids) do
    from(task_attempt in TaskAttempt,
      join: task in Task,
      on: task.id == task_attempt.task_id,
      where: task_attempt.child_profile_id == ^child_profile_id and task.skill_id in ^skill_ids,
      select:
        {task.skill_id, task_attempt.task_id, task_attempt.is_correct, task_attempt.hint_used}
    )
    |> Repo.all()
    |> Enum.group_by(fn {skill_id, _task_id, _is_correct, _hint_used} -> skill_id end)
  end

  defp build_skill_progress(skill, tasks, attempts) do
    completed_task_ids =
      attempts
      |> Enum.filter(fn {_skill_id, _task_id, is_correct, _hint_used} -> is_correct end)
      |> Enum.map(fn {_skill_id, task_id, _is_correct, _hint_used} -> task_id end)
      |> MapSet.new()

    deferred_task_ids = deferred_task_ids(attempts)
    total_tasks = length(tasks)
    completed_tasks = MapSet.size(completed_task_ids)

    status = skill_status(total_tasks, completed_tasks, attempts, deferred_task_ids)

    incorrect_attempts_count =
      Enum.count(attempts, fn {_skill_id, _task_id, is_correct, _hint_used} -> not is_correct end)

    hints_used_count =
      Enum.count(attempts, fn {_skill_id, _task_id, _is_correct, hint_used} -> hint_used end)

    %{
      id: skill.id,
      title: skill.title,
      area: skill.area,
      area_label: area_label(skill.area),
      status: status,
      status_label: status_label(status),
      status_description: status_description(status),
      total_tasks: total_tasks,
      completed_tasks: completed_tasks,
      completion_percentage: percentage(completed_tasks, total_tasks),
      attempts_count: length(attempts),
      incorrect_attempts_count: incorrect_attempts_count,
      hints_used_count: hints_used_count,
      tasks_needing_review_count: MapSet.size(deferred_task_ids),
      recommendation_priority:
        recommendation_priority(status, incorrect_attempts_count, hints_used_count)
    }
  end

  defp deferred_task_ids(attempts) do
    attempts
    |> Enum.group_by(fn {_skill_id, task_id, _is_correct, _hint_used} -> task_id end)
    |> Enum.reduce(MapSet.new(), fn {task_id, task_attempts}, deferred_task_ids ->
      solved? =
        Enum.any?(task_attempts, fn {_skill_id, _task_id, is_correct, _hint_used} ->
          is_correct
        end)

      incorrect_attempts_count =
        Enum.count(task_attempts, fn {_skill_id, _task_id, is_correct, _hint_used} ->
          not is_correct
        end)

      if not solved? and incorrect_attempts_count >= 3 do
        MapSet.put(deferred_task_ids, task_id)
      else
        deferred_task_ids
      end
    end)
  end

  defp skill_status(total_tasks, completed_tasks, attempts, deferred_task_ids) do
    cond do
      total_tasks > 0 and completed_tasks == total_tasks -> :mastered
      MapSet.size(deferred_task_ids) > 0 -> :needs_review
      attempts == [] -> :not_started
      true -> :in_progress
    end
  end

  defp build_progress_summary(skills_progress) do
    total_tasks = Enum.sum_by(skills_progress, & &1.total_tasks)
    completed_tasks = Enum.sum_by(skills_progress, & &1.completed_tasks)

    %{
      total_skills: length(skills_progress),
      mastered_skills: Enum.count(skills_progress, &(&1.status == :mastered)),
      skills_needing_review: Enum.count(skills_progress, &(&1.status == :needs_review)),
      total_tasks: total_tasks,
      completed_tasks: completed_tasks,
      completion_percentage: percentage(completed_tasks, total_tasks)
    }
  end

  defp build_recommendations(skills_progress) do
    skills_progress
    |> Enum.filter(&(&1.status in [:needs_review, :in_progress]))
    |> Enum.reject(&(&1.recommendation_priority == :low))
    |> Enum.sort_by(&priority_rank(&1.recommendation_priority))
    |> Enum.map(fn skill ->
      %{
        skill_id: skill.id,
        priority: skill.recommendation_priority,
        title: "Повторить: #{skill.title}",
        message:
          "Было три сложных попытки без успешного ответа. Полезно вернуться к этому навыку в спокойном темпе и пройти более простые примеры."
      }
    end)
  end

  defp area_label("math"), do: "Счёт"
  defp area_label("reading"), do: "Чтение"
  defp area_label("logic"), do: "Логика"
  defp area_label(area), do: area

  defp status_label(:mastered), do: "Освоено"
  defp status_label(:needs_review), do: "Нужно повторить"
  defp status_label(:in_progress), do: "В процессе"
  defp status_label(:not_started), do: "Не начато"

  defp status_description(:mastered), do: "Все задания навыка выполнены правильно."

  defp status_description(:needs_review),
    do: "Есть задание, которое пока требует дополнительной поддержки."

  defp status_description(:in_progress),
    do: "Ребёнок уже начал практику и постепенно осваивает навык."

  defp status_description(:not_started), do: "Практика по этому навыку ещё не началась."

  defp recommendation_priority(:needs_review, incorrect, _hints) when incorrect >= 5, do: :high
  defp recommendation_priority(:needs_review, _incorrect, _hints), do: :high
  defp recommendation_priority(:in_progress, _incorrect, hints) when hints >= 2, do: :medium
  defp recommendation_priority(_status, _incorrect, _hints), do: :low

  defp priority_rank(:high), do: 0
  defp priority_rank(:medium), do: 1
  defp priority_rank(:low), do: 2

  defp diagnostic_recommendation_message(nil),
    do: "Диагностика пройдена уверенно. Можно продолжать задания текущего уровня."

  defp diagnostic_recommendation_message(area) do
    "Рекомендуем начать с базовых заданий по направлению «#{area.area_label}» и двигаться маленькими шагами."
  end

  defp percentage(_completed, 0), do: 0
  defp percentage(completed, total), do: round(completed / total * 100)

  defp next_attempt_number(child_profile_id, task_id) do
    previous_attempts_count =
      from(task_attempt in TaskAttempt,
        where:
          task_attempt.child_profile_id == ^child_profile_id and
            task_attempt.task_id == ^task_id,
        select: count(task_attempt.id)
      )
      |> Repo.one()

    previous_attempts_count + 1
  end

  defp stringify_keys(attrs) do
    Enum.into(attrs, %{}, fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} -> {key, value}
    end)
  end
end
