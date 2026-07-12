defmodule BackendWeb.TaskController do
  use BackendWeb, :controller

  alias Backend.Content
  alias Backend.Content.Task

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    tasks = Content.list_tasks()
    render(conn, :index, tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- Content.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Content.get_task!(id)
    render(conn, :show, task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Content.get_task!(id)

    with {:ok, %Task{} = task} <- Content.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Content.get_task!(id)

    with {:ok, %Task{}} <- Content.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
