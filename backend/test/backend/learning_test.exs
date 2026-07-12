defmodule Backend.LearningTest do
  use Backend.DataCase

  alias Backend.Learning

  describe "child_profiles" do
    alias Backend.Learning.ChildProfile

    import Backend.AccountsFixtures
    import Backend.LearningFixtures

    @invalid_attrs %{parent_id: nil, name: nil, age: nil}

    test "list_child_profiles/0 returns all child_profiles" do
      child_profile = child_profile_fixture()
      assert Learning.list_child_profiles() == [child_profile]
    end

    test "get_child_profile!/1 returns the child_profile with given id" do
      child_profile = child_profile_fixture()
      assert Learning.get_child_profile!(child_profile.id) == child_profile
    end

    test "create_child_profile/1 with valid data creates a child_profile" do
      parent = parent_fixture()
      valid_attrs = %{parent_id: parent.id, name: "some name", age: 6}

      assert {:ok, %ChildProfile{} = child_profile} = Learning.create_child_profile(valid_attrs)
      assert child_profile.parent_id == parent.id
      assert child_profile.name == "some name"
      assert child_profile.age == 6
    end

    test "create_child_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Learning.create_child_profile(@invalid_attrs)
    end

    test "update_child_profile/2 with valid data updates the child_profile" do
      child_profile = child_profile_fixture()
      update_attrs = %{name: "some updated name", age: 7}

      assert {:ok, %ChildProfile{} = child_profile} =
               Learning.update_child_profile(child_profile, update_attrs)

      assert child_profile.name == "some updated name"
      assert child_profile.age == 7
    end

    test "update_child_profile/2 with invalid data returns error changeset" do
      child_profile = child_profile_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Learning.update_child_profile(child_profile, @invalid_attrs)

      assert child_profile == Learning.get_child_profile!(child_profile.id)
    end

    test "delete_child_profile/1 deletes the child_profile" do
      child_profile = child_profile_fixture()
      assert {:ok, %ChildProfile{}} = Learning.delete_child_profile(child_profile)
      assert_raise Ecto.NoResultsError, fn -> Learning.get_child_profile!(child_profile.id) end
    end

    test "change_child_profile/1 returns a child_profile changeset" do
      child_profile = child_profile_fixture()
      assert %Ecto.Changeset{} = Learning.change_child_profile(child_profile)
    end
  end

  describe "task_attempts" do
    alias Backend.Learning.TaskAttempt

    import Backend.ContentFixtures
    import Backend.LearningFixtures

    @invalid_attrs %{child_profile_id: nil, task_id: nil, selected_answer: nil, hint_used: nil}

    test "list_task_attempts/0 returns all task_attempts" do
      task_attempt = task_attempt_fixture()
      assert Learning.list_task_attempts() == [task_attempt]
    end

    test "get_task_attempt!/1 returns the task_attempt with given id" do
      task_attempt = task_attempt_fixture()
      assert Learning.get_task_attempt!(task_attempt.id) == task_attempt
    end

    test "create_task_attempt/1 with valid data creates a task_attempt" do
      child_profile = child_profile_fixture()
      task = task_fixture(%{correct_answer: "right"})

      valid_attrs = %{
        child_profile_id: child_profile.id,
        task_id: task.id,
        selected_answer: "right",
        hint_used: true
      }

      assert {:ok, %TaskAttempt{} = task_attempt} = Learning.create_task_attempt(valid_attrs)
      assert task_attempt.child_profile_id == child_profile.id
      assert task_attempt.task_id == task.id
      assert task_attempt.selected_answer == "right"
      assert task_attempt.is_correct == true
      assert task_attempt.hint_used == true
      assert task_attempt.attempt_number == 1
    end

    test "create_task_attempt/1 grades wrong answers on the backend" do
      child_profile = child_profile_fixture()
      task = task_fixture(%{correct_answer: "right"})

      attrs = %{
        child_profile_id: child_profile.id,
        task_id: task.id,
        selected_answer: "left",
        hint_used: false
      }

      assert {:ok, %TaskAttempt{} = task_attempt} = Learning.create_task_attempt(attrs)
      assert task_attempt.is_correct == false
      assert task_attempt.attempt_number == 1
    end

    test "create_task_attempt/1 increments attempt_number for repeated task attempts" do
      child_profile = child_profile_fixture()
      task = task_fixture(%{correct_answer: "right"})

      attrs = %{
        child_profile_id: child_profile.id,
        task_id: task.id,
        selected_answer: "left",
        hint_used: true
      }

      assert {:ok, %TaskAttempt{attempt_number: 1}} = Learning.create_task_attempt(attrs)
      assert {:ok, %TaskAttempt{attempt_number: 2}} = Learning.create_task_attempt(attrs)
    end

    test "create_task_attempt/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Learning.create_task_attempt(@invalid_attrs)
    end

    test "update_task_attempt/2 with valid data updates the task_attempt" do
      task_attempt = task_attempt_fixture()

      update_attrs = %{
        selected_answer: "some updated selected_answer",
        is_correct: false,
        hint_used: false,
        attempt_number: 43
      }

      assert {:ok, %TaskAttempt{} = task_attempt} =
               Learning.update_task_attempt(task_attempt, update_attrs)

      assert task_attempt.selected_answer == "some updated selected_answer"
      assert task_attempt.is_correct == false
      assert task_attempt.hint_used == false
      assert task_attempt.attempt_number == 43
    end

    test "update_task_attempt/2 with invalid data returns error changeset" do
      task_attempt = task_attempt_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Learning.update_task_attempt(task_attempt, @invalid_attrs)

      assert task_attempt == Learning.get_task_attempt!(task_attempt.id)
    end

    test "delete_task_attempt/1 deletes the task_attempt" do
      task_attempt = task_attempt_fixture()
      assert {:ok, %TaskAttempt{}} = Learning.delete_task_attempt(task_attempt)
      assert_raise Ecto.NoResultsError, fn -> Learning.get_task_attempt!(task_attempt.id) end
    end

    test "change_task_attempt/1 returns a task_attempt changeset" do
      task_attempt = task_attempt_fixture()
      assert %Ecto.Changeset{} = Learning.change_task_attempt(task_attempt)
    end
  end

  describe "next_task_for_child/1" do
    alias Backend.Learning.TaskAttempt

    import Backend.ContentFixtures
    import Backend.LearningFixtures

    test "returns the easiest unanswered age-appropriate task" do
      child_profile = child_profile_fixture(%{age: 6})
      matching_skill = skill_fixture(%{age_min: 5, age_max: 7})
      older_skill = skill_fixture(%{age_min: 8, age_max: 9})

      harder_task = task_fixture(%{skill: matching_skill, difficulty: 3})
      easier_task = task_fixture(%{skill: matching_skill, difficulty: 1})
      _too_old_task = task_fixture(%{skill: older_skill, difficulty: 1})

      assert {:ok, task} = Learning.next_task_for_child(child_profile.id)
      assert task.id == easier_task.id
      refute task.id == harder_task.id
    end

    test "skips tasks already answered correctly by the child" do
      child_profile = child_profile_fixture(%{age: 6})
      skill = skill_fixture(%{age_min: 5, age_max: 7})

      completed_task = task_fixture(%{skill: skill, difficulty: 1, correct_answer: "right"})
      next_task = task_fixture(%{skill: skill, difficulty: 2})

      assert {:ok, %Backend.Learning.TaskAttempt{}} =
               Learning.create_task_attempt(%{
                 child_profile_id: child_profile.id,
                 task_id: completed_task.id,
                 selected_answer: "right",
                 hint_used: false
               })

      assert {:ok, task} = Learning.next_task_for_child(child_profile.id)
      assert task.id == next_task.id
    end

    test "returns an error when the child profile does not exist" do
      assert {:error, :child_profile_not_found} = Learning.next_task_for_child(-1)
    end

    test "returns an error when no task is available" do
      child_profile = child_profile_fixture(%{age: 6})

      assert {:error, :no_task_available} = Learning.next_task_for_child(child_profile.id)
    end

    test "skips a task after three incorrect answers" do
      child_profile = child_profile_fixture(%{age: 6})
      skill = skill_fixture(%{age_min: 5, age_max: 7})
      deferred_task = task_fixture(%{skill: skill, difficulty: 1, correct_answer: "right"})
      next_task = task_fixture(%{skill: skill, difficulty: 2})

      for _ <- 1..3 do
        assert {:ok, %TaskAttempt{is_correct: false}} =
                 Learning.create_task_attempt(%{
                   child_profile_id: child_profile.id,
                   task_id: deferred_task.id,
                   selected_answer: "left",
                   hint_used: false
                 })
      end

      assert {:ok, task} = Learning.next_task_for_child(child_profile.id)
      assert task.id == next_task.id
    end

    test "mixes areas between equally difficult tasks after a correct answer" do
      child_profile = child_profile_fixture(%{age: 6})
      math_skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})
      reading_skill = skill_fixture(%{area: "reading", age_min: 5, age_max: 7})

      completed_math = task_fixture(%{skill: math_skill, difficulty: 1, correct_answer: "yes"})
      _next_math = task_fixture(%{skill: math_skill, difficulty: 1})
      reading_task = task_fixture(%{skill: reading_skill, difficulty: 1})

      assert {:ok, _attempt} =
               Learning.create_task_attempt(%{
                 child_profile_id: child_profile.id,
                 task_id: completed_math.id,
                 selected_answer: "yes",
                 hint_used: false
               })

      assert {:ok, next_task} = Learning.next_task_for_child(child_profile.id)
      assert next_task.id == reading_task.id
    end
  end

  describe "submit_task_answer/3" do
    import Backend.ContentFixtures
    import Backend.LearningFixtures

    test "returns a continue response after a correct answer" do
      child_profile = child_profile_fixture()
      task = task_fixture(%{correct_answer: "right"})

      assert {:ok, %{task_attempt: attempt, feedback: feedback}} =
               Learning.submit_task_answer(child_profile.id, task.id, %{
                 selected_answer: "right",
                 hint_used: false
               })

      assert attempt.is_correct == true

      assert feedback == %{
               result: :correct,
               action: :continue,
               message: "Отлично! Ты справился.",
               can_continue: true
             }
    end

    test "returns progressively stronger help after wrong answers" do
      child_profile = child_profile_fixture()

      task =
        task_fixture(%{
          correct_answer: "right",
          hint1: "Сначала посчитай предметы.",
          hint2: "Слева 3, а справа 5.",
          explanation: "5 больше, чем 3."
        })

      assert {:ok, %{feedback: %{action: :show_hint1, hint: "Сначала посчитай предметы."}}} =
               Learning.submit_task_answer(child_profile.id, task.id, %{selected_answer: "left"})

      assert {:ok, %{feedback: %{action: :show_hint2, hint: "Слева 3, а справа 5."}}} =
               Learning.submit_task_answer(child_profile.id, task.id, %{selected_answer: "left"})

      assert {:ok, %{feedback: %{action: :review_later, explanation: "5 больше, чем 3."}}} =
               Learning.submit_task_answer(child_profile.id, task.id, %{selected_answer: "left"})
    end

    test "returns errors when the child or task does not exist" do
      child_profile = child_profile_fixture()
      task = task_fixture()

      assert {:error, :child_profile_not_found} =
               Learning.submit_task_answer(-1, task.id, %{selected_answer: "right"})

      assert {:error, :task_not_found} =
               Learning.submit_task_answer(child_profile.id, -1, %{selected_answer: "right"})
    end
  end

  describe "progress_for_child/1" do
    alias Backend.Learning.TaskAttempt

    import Backend.ContentFixtures
    import Backend.LearningFixtures

    test "builds a progress report and recommends skills that need review" do
      child_profile = child_profile_fixture(%{age: 6})
      math_skill = skill_fixture(%{title: "Счет предметов", area: "math", age_min: 5, age_max: 7})

      logic_skill =
        skill_fixture(%{title: "Последовательности", area: "logic", age_min: 5, age_max: 7})

      completed_task = task_fixture(%{skill: math_skill, correct_answer: "right"})
      deferred_task = task_fixture(%{skill: math_skill, correct_answer: "right"})
      _not_started_task = task_fixture(%{skill: logic_skill})

      assert {:ok, %TaskAttempt{is_correct: true}} =
               Learning.create_task_attempt(%{
                 child_profile_id: child_profile.id,
                 task_id: completed_task.id,
                 selected_answer: "right",
                 hint_used: false
               })

      for _ <- 1..3 do
        assert {:ok, %TaskAttempt{is_correct: false}} =
                 Learning.create_task_attempt(%{
                   child_profile_id: child_profile.id,
                   task_id: deferred_task.id,
                   selected_answer: "left",
                   hint_used: true
                 })
      end

      assert {:ok, progress} = Learning.progress_for_child(child_profile.id)

      assert progress.child == %{id: child_profile.id, name: child_profile.name, age: 6}

      assert progress.summary == %{
               total_skills: 2,
               mastered_skills: 0,
               skills_needing_review: 1,
               total_tasks: 3,
               completed_tasks: 1,
               completion_percentage: 33
             }

      assert %{
               status: :needs_review,
               total_tasks: 2,
               completed_tasks: 1,
               completion_percentage: 50,
               incorrect_attempts_count: 3,
               hints_used_count: 3,
               tasks_needing_review_count: 1
             } = Enum.find(progress.skills, &(&1.id == math_skill.id))

      assert %{status: :not_started, completion_percentage: 0} =
               Enum.find(progress.skills, &(&1.id == logic_skill.id))

      assert progress.recommendations == [
               %{
                 skill_id: math_skill.id,
                 priority: :high,
                 title: "Повторить: Счет предметов",
                 message:
                   "Было три сложных попытки без успешного ответа. Полезно вернуться к этому навыку в спокойном темпе и пройти более простые примеры."
               }
             ]
    end

    test "returns an error when the child profile does not exist" do
      assert {:error, :child_profile_not_found} = Learning.progress_for_child(-1)
    end
  end

  describe "initial diagnostic" do
    alias Backend.Learning.DiagnosticAnswer
    alias Backend.Learning.DiagnosticSession

    import Backend.ContentFixtures
    import Backend.LearningFixtures

    test "starts a session and returns one introductory task for each core area" do
      child_profile = child_profile_fixture(%{age: 6})

      math_skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})
      reading_skill = skill_fixture(%{area: "reading", age_min: 5, age_max: 7})
      logic_skill = skill_fixture(%{area: "logic", age_min: 5, age_max: 7})

      math_task = task_fixture(%{skill: math_skill, difficulty: 1})
      _harder_math_task = task_fixture(%{skill: math_skill, difficulty: 2})
      _reading_task = task_fixture(%{skill: reading_skill, difficulty: 1})
      _logic_task = task_fixture(%{skill: logic_skill, difficulty: 1})

      assert {:ok, %{session: %DiagnosticSession{} = session, task: task}} =
               Learning.start_diagnostic(child_profile.id)

      assert session.child_profile_id == child_profile.id
      assert session.status == "in_progress"
      assert task.area == "math"
      assert task.task.id == math_task.id
    end

    test "grades answers and returns a completed starting route" do
      child_profile = child_profile_fixture(%{age: 6})

      math_task = diagnostic_task_fixture("math", "right")
      reading_task = diagnostic_task_fixture("reading", "yes")
      logic_task = diagnostic_task_fixture("logic", "blue")

      assert {:ok, %{session: session, task: %{task: first_task}}} =
               Learning.start_diagnostic(child_profile.id)

      assert first_task.id == math_task.id

      assert {:ok,
              %{answer: %DiagnosticAnswer{is_correct: true}, next_task: %{task: second_task}}} =
               Learning.submit_diagnostic_answer(session.id, first_task.id, %{
                 selected_answer: "right"
               })

      assert second_task.id == reading_task.id

      assert {:ok,
              %{answer: %DiagnosticAnswer{is_correct: false}, next_task: %{task: third_task}}} =
               Learning.submit_diagnostic_answer(session.id, second_task.id, %{
                 selected_answer: "no"
               })

      assert third_task.id == logic_task.id

      assert {:ok, %{completed: true, session: completed_session, result: result}} =
               Learning.submit_diagnostic_answer(session.id, third_task.id, %{
                 selected_answer: "blue"
               })

      assert completed_session.status == "completed"
      assert result.total_areas == 3
      assert result.confident_areas == 2

      assert [%{area: "reading", result: :start_from_basics}] = result.recommended_focus
    end

    test "does not allow an answer for a task outside the diagnostic route" do
      child_profile = child_profile_fixture(%{age: 6})
      _math_task = diagnostic_task_fixture("math", "right")
      unrelated_task = task_fixture()

      assert {:ok, %{session: session}} = Learning.start_diagnostic(child_profile.id)

      assert {:error, :unexpected_diagnostic_task} =
               Learning.submit_diagnostic_answer(session.id, unrelated_task.id, %{
                 selected_answer: "right"
               })
    end

    test "returns an error without diagnostic content" do
      child_profile = child_profile_fixture(%{age: 6})

      assert {:error, :no_diagnostic_tasks_available} =
               Learning.start_diagnostic(child_profile.id)
    end

    defp diagnostic_task_fixture(area, correct_answer) do
      skill = skill_fixture(%{area: area, age_min: 5, age_max: 7})
      task_fixture(%{skill: skill, correct_answer: correct_answer, difficulty: 1})
    end
  end
end
