defmodule Backend.Demo do
  @moduledoc """
  Creates and reuses the small, deterministic data set used by the browser demo.
  """

  import Ecto.Query, warn: false

  alias Backend.Accounts
  alias Backend.Accounts.Parent
  alias Backend.Content
  alias Backend.Content.Skill
  alias Backend.Content.Task
  alias Backend.Learning
  alias Backend.Learning.ChildProfile
  alias Backend.Repo

  @demo_parent_email "demo@growly.local"
  @demo_child_name "Миша"
  @demo_skill_title "Счет предметов до 10"
  @demo_task_question "Где больше яблок?"

  @doc """
  Returns the demo parent, child, skill, and task, creating each record only
  when it does not already exist.
  """
  def ensure_data do
    with {:ok, parent} <- ensure_parent(),
         {:ok, child} <- ensure_child(parent),
         {:ok, skill} <- ensure_skill(),
         {:ok, task} <- ensure_task(skill) do
      {:ok, %{parent: parent, child: child, skill: skill, task: task}}
    end
  end

  defp ensure_parent do
    case Repo.get_by(Parent, email: @demo_parent_email) do
      nil -> Accounts.create_parent(%{email: @demo_parent_email})
      parent -> {:ok, parent}
    end
  end

  defp ensure_child(parent) do
    child =
      from(child_profile in ChildProfile,
        where:
          child_profile.parent_id == ^parent.id and
            child_profile.name == ^@demo_child_name and
            child_profile.age == 6,
        limit: 1
      )
      |> Repo.one()

    case child do
      nil ->
        Learning.create_child_profile(%{parent_id: parent.id, name: @demo_child_name, age: 6})

      child ->
        {:ok, child}
    end
  end

  defp ensure_skill do
    case Repo.get_by(Skill, title: @demo_skill_title, area: "math") do
      nil ->
        Content.create_skill(%{
          title: @demo_skill_title,
          area: "math",
          age_min: 5,
          age_max: 7
        })

      skill ->
        {:ok, skill}
    end
  end

  defp ensure_task(skill) do
    case Repo.get_by(Task, skill_id: skill.id, question: @demo_task_question) do
      nil ->
        Content.create_task(%{
          skill_id: skill.id,
          type: "choose_side",
          question: @demo_task_question,
          options: %{"left" => 3, "right" => 5},
          correct_answer: "right",
          difficulty: 1,
          hint1: "Посчитай яблоки слева и справа.",
          hint2: "Слева 3 яблока, а справа 5 яблок.",
          explanation: "Больше там, где число больше: 5 больше, чем 3."
        })

      task ->
        {:ok, task}
    end
  end
end
