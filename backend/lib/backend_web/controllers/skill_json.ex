defmodule BackendWeb.SkillJSON do
  alias Backend.Content.Skill

  @doc """
  Renders a list of skills.
  """
  def index(%{skills: skills}) do
    %{data: for(skill <- skills, do: data(skill))}
  end

  @doc """
  Renders a single skill.
  """
  def show(%{skill: skill}) do
    %{data: data(skill)}
  end

  defp data(%Skill{} = skill) do
    %{
      id: skill.id,
      title: skill.title,
      area: skill.area,
      age_min: skill.age_min,
      age_max: skill.age_max
    }
  end
end
