defmodule BackendWeb.ParentJSON do
  alias Backend.Accounts.Parent

  @doc """
  Renders a list of parents.
  """
  def index(%{parents: parents}) do
    %{data: for(parent <- parents, do: data(parent))}
  end

  @doc """
  Renders a single parent.
  """
  def show(%{parent: parent}) do
    %{data: data(parent)}
  end

  defp data(%Parent{} = parent) do
    %{
      id: parent.id,
      email: parent.email
    }
  end
end
