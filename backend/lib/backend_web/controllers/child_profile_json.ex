defmodule BackendWeb.ChildProfileJSON do
  alias Backend.Learning.ChildProfile

  @doc """
  Renders a list of child_profiles.
  """
  def index(%{child_profiles: child_profiles}) do
    %{data: for(child_profile <- child_profiles, do: data(child_profile))}
  end

  @doc """
  Renders a single child_profile.
  """
  def show(%{child_profile: child_profile}) do
    %{data: data(child_profile)}
  end

  defp data(%ChildProfile{} = child_profile) do
    %{
      id: child_profile.id,
      parent_id: child_profile.parent_id,
      name: child_profile.name,
      age: child_profile.age
    }
  end
end
