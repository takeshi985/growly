defmodule BackendWeb.DiagnosticAnswerController do
  use BackendWeb, :controller

  alias Backend.Learning

  def create(conn, %{
        "session_id" => session_id,
        "task_id" => task_id,
        "answer" => answer_params
      }) do
    case Learning.submit_diagnostic_answer(session_id, task_id, answer_params) do
      {:ok, diagnostic} ->
        render(conn, :show, diagnostic: diagnostic)

      {:error, :diagnostic_session_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{session_id: ["does not exist"]}})

      {:error, :diagnostic_completed} ->
        conn
        |> put_status(:conflict)
        |> json(%{errors: %{diagnostic: ["already completed"]}})

      {:error, :unexpected_diagnostic_task} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{task_id: ["is not the expected diagnostic task"]}})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: BackendWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
