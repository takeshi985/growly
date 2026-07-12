defmodule BackendWeb.MobileV1Controller do
  use BackendWeb, :controller

  alias Backend.Learning
  alias BackendWeb.MobileV1JSON

  def session(conn, %{"child_id" => child_id}) do
    case Learning.learning_session_for_child(child_id) do
      {:ok, session} -> json(conn, MobileV1JSON.session(session))
      {:error, :child_profile_not_found} -> child_not_found(conn)
    end
  end

  def answer(conn, %{
        "child_id" => child_id,
        "task_id" => task_id,
        "answer" => answer_params
      }) do
    case Learning.submit_mobile_task_answer(child_id, task_id, answer_params) do
      {:ok, answer_result} -> json(conn, MobileV1JSON.answer(answer_result))
      {:error, :child_profile_not_found} -> child_not_found(conn)
      {:error, :task_not_found} -> task_not_found(conn)
      {:error, %Ecto.Changeset{} = changeset} -> changeset_error(conn, changeset)
    end
  end

  def progress(conn, %{"child_id" => child_id}) do
    case Learning.progress_for_child(child_id) do
      {:ok, progress} -> json(conn, %{data: progress})
      {:error, :child_profile_not_found} -> child_not_found(conn)
    end
  end

  def start_diagnostic(conn, %{"child_id" => child_id}) do
    case Learning.start_diagnostic(child_id) do
      {:ok, diagnostic} ->
        conn
        |> put_status(:created)
        |> json(MobileV1JSON.diagnostic_started(diagnostic))

      {:error, :child_profile_not_found} ->
        child_not_found(conn)

      {:error, :no_diagnostic_tasks_available} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{diagnostic: ["no age-appropriate tasks available"]}})
    end
  end

  def diagnostic_answer(conn, %{
        "session_id" => session_id,
        "task_id" => task_id,
        "answer" => answer_params
      }) do
    case Learning.submit_diagnostic_answer(session_id, task_id, answer_params) do
      {:ok, diagnostic} ->
        json(conn, MobileV1JSON.diagnostic_answer(diagnostic))

      {:error, reason}
      when reason in [
             :diagnostic_session_not_found,
             :diagnostic_completed,
             :unexpected_diagnostic_task
           ] ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{diagnostic: [to_string(reason)]}})

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset_error(conn, changeset)
    end
  end

  defp child_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{child_id: ["does not exist"]}})
  end

  defp task_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json(%{errors: %{task_id: ["does not exist"]}})
  end

  defp changeset_error(conn, changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BackendWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
