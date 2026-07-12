defmodule BackendWeb.ChildNextTaskController do
  use BackendWeb, :controller

  alias Backend.Content.Task
  alias Backend.Learning

  action_fallback(BackendWeb.FallbackController)

  def show(conn, %{"child_id" => child_id}) do
    case Learning.next_task_for_child(child_id) do
      {:ok, %Task{} = task} ->
        render(conn, :show, task: task)

      {:error, :child_profile_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{child_id: ["does not exist"]}})

      {:error, :no_task_available} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{task: ["no task available"]}})
    end
  end
end
