defmodule Backend.LearningFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Learning` context.
  """

  @doc """
  Generate a child_profile.
  """
  def child_profile_fixture(attrs \\ %{}) do
    parent = Map.get_lazy(attrs, :parent, fn -> Backend.AccountsFixtures.parent_fixture() end)

    {:ok, child_profile} =
      attrs
      |> Map.drop([:parent])
      |> Enum.into(%{
        age: 6,
        name: "some name",
        parent_id: parent.id
      })
      |> Backend.Learning.create_child_profile()

    child_profile
  end

  @doc """
  Generate a task_attempt.
  """
  def task_attempt_fixture(attrs \\ %{}) do
    child_profile =
      Map.get_lazy(attrs, :child_profile, fn -> child_profile_fixture() end)

    task = Map.get_lazy(attrs, :task, fn -> Backend.ContentFixtures.task_fixture() end)

    {:ok, task_attempt} =
      attrs
      |> Map.drop([:child_profile, :task])
      |> Enum.into(%{
        child_profile_id: child_profile.id,
        hint_used: true,
        selected_answer: task.correct_answer,
        task_id: task.id
      })
      |> Backend.Learning.create_task_attempt()

    task_attempt
  end
end
