defmodule BackendWeb.ChildProgressController do
  use BackendWeb, :controller

  alias Backend.Learning

  def show(conn, %{"child_id" => child_id}) do
    case Learning.progress_for_child(child_id) do
      {:ok, progress} ->
        render(conn, :show, progress: progress)

      {:error, :child_profile_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{child_id: ["does not exist"]}})
    end
  end
end
