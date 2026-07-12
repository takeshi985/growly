defmodule BackendWeb.TaskAttemptController do
  use BackendWeb, :controller

  alias Backend.Learning
  alias Backend.Learning.TaskAttempt

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    task_attempts = Learning.list_task_attempts()
    render(conn, :index, task_attempts: task_attempts)
  end

  def create(conn, %{"task_attempt" => task_attempt_params}) do
    with {:ok, %TaskAttempt{} = task_attempt} <- Learning.create_task_attempt(task_attempt_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/task_attempts/#{task_attempt}")
      |> render(:show, task_attempt: task_attempt)
    end
  end

  def show(conn, %{"id" => id}) do
    task_attempt = Learning.get_task_attempt!(id)
    render(conn, :show, task_attempt: task_attempt)
  end

  def update(conn, %{"id" => id, "task_attempt" => task_attempt_params}) do
    task_attempt = Learning.get_task_attempt!(id)

    with {:ok, %TaskAttempt{} = task_attempt} <-
           Learning.update_task_attempt(task_attempt, task_attempt_params) do
      render(conn, :show, task_attempt: task_attempt)
    end
  end

  def delete(conn, %{"id" => id}) do
    task_attempt = Learning.get_task_attempt!(id)

    with {:ok, %TaskAttempt{}} <- Learning.delete_task_attempt(task_attempt) do
      send_resp(conn, :no_content, "")
    end
  end
end
