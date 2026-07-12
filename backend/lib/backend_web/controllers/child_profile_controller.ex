defmodule BackendWeb.ChildProfileController do
  use BackendWeb, :controller

  alias Backend.Learning
  alias Backend.Learning.ChildProfile

  action_fallback BackendWeb.FallbackController

  def index(conn, _params) do
    child_profiles = Learning.list_child_profiles()
    render(conn, :index, child_profiles: child_profiles)
  end

  def create(conn, %{"child_profile" => child_profile_params}) do
    with {:ok, %ChildProfile{} = child_profile} <-
           Learning.create_child_profile(child_profile_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/child_profiles/#{child_profile}")
      |> render(:show, child_profile: child_profile)
    end
  end

  def show(conn, %{"id" => id}) do
    child_profile = Learning.get_child_profile!(id)
    render(conn, :show, child_profile: child_profile)
  end

  def update(conn, %{"id" => id, "child_profile" => child_profile_params}) do
    child_profile = Learning.get_child_profile!(id)

    with {:ok, %ChildProfile{} = child_profile} <-
           Learning.update_child_profile(child_profile, child_profile_params) do
      render(conn, :show, child_profile: child_profile)
    end
  end

  def delete(conn, %{"id" => id}) do
    child_profile = Learning.get_child_profile!(id)

    with {:ok, %ChildProfile{}} <- Learning.delete_child_profile(child_profile) do
      send_resp(conn, :no_content, "")
    end
  end
end
