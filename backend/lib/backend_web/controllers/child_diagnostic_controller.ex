defmodule BackendWeb.ChildDiagnosticController do
  use BackendWeb, :controller

  alias Backend.Learning

  def create(conn, %{"child_id" => child_id}) do
    case Learning.start_diagnostic(child_id) do
      {:ok, diagnostic} ->
        conn
        |> put_status(:created)
        |> render(:started, diagnostic: diagnostic)

      {:error, :child_profile_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{errors: %{child_id: ["does not exist"]}})

      {:error, :no_diagnostic_tasks_available} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{diagnostic: ["no age-appropriate tasks available"]}})
    end
  end
end
