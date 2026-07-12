defmodule Backend.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Content` context.
  """

  @doc """
  Generate a skill.
  """
  def skill_fixture(attrs \\ %{}) do
    {:ok, skill} =
      attrs
      |> Enum.into(%{
        age_max: 42,
        age_min: 42,
        area: "some area",
        title: "some title"
      })
      |> Backend.Content.create_skill()

    skill
  end

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    skill = Map.get_lazy(attrs, :skill, fn -> skill_fixture() end)

    {:ok, task} =
      attrs
      |> Map.drop([:skill])
      |> Enum.into(%{
        correct_answer: "some correct_answer",
        difficulty: 42,
        explanation: "some explanation",
        hint1: "some hint1",
        hint2: "some hint2",
        options: %{},
        question: "some question",
        skill_id: skill.id,
        type: "some type"
      })
      |> Backend.Content.create_task()

    task
  end
end
