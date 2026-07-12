defmodule BackendWeb.ParentController do
  use BackendWeb, :controller

  alias Backend.Accounts
  alias Backend.Accounts.Parent

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    parents = Accounts.list_parents()
    render(conn, :index, parents: parents)
  end

  def create(conn, %{"parent" => parent_params}) do
    with {:ok, %Parent{} = parent} <- Accounts.create_parent(parent_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/parents/#{parent}")
      |> render(:show, parent: parent)
    end
  end

  def show(conn, %{"id" => id}) do
    parent = Accounts.get_parent!(id)
    render(conn, :show, parent: parent)
  end

  def update(conn, %{"id" => id, "parent" => parent_params}) do
    parent = Accounts.get_parent!(id)

    with {:ok, %Parent{} = parent} <- Accounts.update_parent(parent, parent_params) do
      render(conn, :show, parent: parent)
    end
  end

  def delete(conn, %{"id" => id}) do
    parent = Accounts.get_parent!(id)

    with {:ok, %Parent{}} <- Accounts.delete_parent(parent) do
      send_resp(conn, :no_content, "")
    end
  end
end
