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
  alias Backend.Learning.TaskAttempt

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

        task =
          from(task in Task,
            join: skill in Skill,
            on: skill.id == task.skill_id,
            where:
              skill.age_min <= ^child_profile.age and
                skill.age_max >= ^child_profile.age and
                task.id not in subquery(completed_task_ids) and
                task.id not in subquery(deferred_task_ids),
            order_by: [asc: task.difficulty, asc: task.id],
            limit: 1
          )
          |> Repo.one()

        case task do
          nil -> {:error, :no_task_available}
          %Task{} = task -> {:ok, task}
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
      message: "Ты хорошо стараешься. Вот еще подсказка.",
      hint: task.hint2,
      can_continue: true
    }
  end

  defp feedback_for(%TaskAttempt{}, %Task{} = task) do
    %{
      result: :incorrect,
      action: :review_later,
      message: "Это задание пока сложное. Мы вернемся к нему позже.",
      explanation: task.explanation,
      can_continue: true
    }
  end

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
