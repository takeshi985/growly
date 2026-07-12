defmodule BackendWeb.ChildProgressJSON do
  @doc """
  Renders the progress data used in the parent section of Growly.
  """
  def show(%{progress: progress}), do: %{data: progress}
end
