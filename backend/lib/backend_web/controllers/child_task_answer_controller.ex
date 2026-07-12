defmodule BackendWeb.ChildTaskAnswerController do
  use BackendWeb, :controller

  alias Backend.Learning

  def create(conn, %{
        "child_id" => child_id,
        "task_id" => task_id,
        "answer" => answer_params
      }) do
    case Learning.submit_task_answer(child_id, task_id, answer_params) do
      {:ok, answer_result} ->
        conn
        |> put_status(:created)
        |> render(:show, answer_result: answer_result)

      {:error, :child_profile_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{child_id: ["does not exist"]}})

      {:error, :task_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{task_id: ["does not exist"]}})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: BackendWeb.ChangesetJSON)
        |> render(:error, changeset: changeset)
    end
  end
end
