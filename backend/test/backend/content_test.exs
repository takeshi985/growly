defmodule Backend.ContentTest do
  use Backend.DataCase

  alias Backend.Content

  describe "skills" do
    alias Backend.Content.Skill

    import Backend.ContentFixtures

    @invalid_attrs %{title: nil, area: nil, age_min: nil, age_max: nil}

    test "list_skills/0 returns all skills" do
      skill = skill_fixture()
      assert Content.list_skills() == [skill]
    end

    test "get_skill!/1 returns the skill with given id" do
      skill = skill_fixture()
      assert Content.get_skill!(skill.id) == skill
    end

    test "create_skill/1 with valid data creates a skill" do
      valid_attrs = %{title: "some title", area: "some area", age_min: 42, age_max: 42}

      assert {:ok, %Skill{} = skill} = Content.create_skill(valid_attrs)
      assert skill.title == "some title"
      assert skill.area == "some area"
      assert skill.age_min == 42
      assert skill.age_max == 42
    end

    test "create_skill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_skill(@invalid_attrs)
    end

    test "update_skill/2 with valid data updates the skill" do
      skill = skill_fixture()

      update_attrs = %{
        title: "some updated title",
        area: "some updated area",
        age_min: 43,
        age_max: 43
      }

      assert {:ok, %Skill{} = skill} = Content.update_skill(skill, update_attrs)
      assert skill.title == "some updated title"
      assert skill.area == "some updated area"
      assert skill.age_min == 43
      assert skill.age_max == 43
    end

    test "update_skill/2 with invalid data returns error changeset" do
      skill = skill_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_skill(skill, @invalid_attrs)
      assert skill == Content.get_skill!(skill.id)
    end

    test "delete_skill/1 deletes the skill" do
      skill = skill_fixture()
      assert {:ok, %Skill{}} = Content.delete_skill(skill)
      assert_raise Ecto.NoResultsError, fn -> Content.get_skill!(skill.id) end
    end

    test "change_skill/1 returns a skill changeset" do
      skill = skill_fixture()
      assert %Ecto.Changeset{} = Content.change_skill(skill)
    end
  end

  describe "tasks" do
    alias Backend.Content.Task

    import Backend.ContentFixtures

    @invalid_attrs %{
      type: nil,
      options: nil,
      question: nil,
      correct_answer: nil,
      difficulty: nil,
      hint1: nil,
      hint2: nil,
      explanation: nil,
      skill_id: nil
    }

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Content.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Content.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      skill = skill_fixture()

      valid_attrs = %{
        type: "some type",
        options: %{},
        question: "some question",
        correct_answer: "some correct_answer",
        difficulty: 42,
        hint1: "some hint1",
        hint2: "some hint2",
        explanation: "some explanation",
        skill_id: skill.id
      }

      assert {:ok, %Task{} = task} = Content.create_task(valid_attrs)
      assert task.skill_id == skill.id
      assert task.type == "some type"
      assert task.options == %{}
      assert task.question == "some question"
      assert task.correct_answer == "some correct_answer"
      assert task.difficulty == 42
      assert task.hint1 == "some hint1"
      assert task.hint2 == "some hint2"
      assert task.explanation == "some explanation"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        type: "some updated type",
        options: %{},
        question: "some updated question",
        correct_answer: "some updated correct_answer",
        difficulty: 43,
        hint1: "some updated hint1",
        hint2: "some updated hint2",
        explanation: "some updated explanation"
      }

      assert {:ok, %Task{} = task} = Content.update_task(task, update_attrs)
      assert task.type == "some updated type"
      assert task.options == %{}
      assert task.question == "some updated question"
      assert task.correct_answer == "some updated correct_answer"
      assert task.difficulty == 43
      assert task.hint1 == "some updated hint1"
      assert task.hint2 == "some updated hint2"
      assert task.explanation == "some updated explanation"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_task(task, @invalid_attrs)
      assert task == Content.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Content.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Content.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Content.change_task(task)
    end
  end
end
