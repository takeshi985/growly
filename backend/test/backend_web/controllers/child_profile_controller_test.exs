defmodule BackendWeb.ChildProfileControllerTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures
  import Backend.LearningFixtures
  alias Backend.Learning.ChildProfile

  @create_attrs %{
    parent_id: nil,
    name: "some name",
    age: 6
  }
  @update_attrs %{
    name: "some updated name",
    age: 7
  }
  @invalid_attrs %{parent_id: nil, name: nil, age: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all child_profiles", %{conn: conn} do
      conn = get(conn, ~p"/api/child_profiles")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create child_profile" do
    test "renders child_profile when data is valid", %{conn: conn} do
      parent = parent_fixture()
      create_attrs = %{@create_attrs | parent_id: parent.id}

      conn = post(conn, ~p"/api/child_profiles", child_profile: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/child_profiles/#{id}")

      assert %{
               "id" => ^id,
               "age" => 6,
               "name" => "some name",
               "parent_id" => parent_id
             } = json_response(conn, 200)["data"]

      assert parent_id == parent.id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/child_profiles", child_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update child_profile" do
    setup [:create_child_profile]

    test "renders child_profile when data is valid", %{
      conn: conn,
      child_profile: %ChildProfile{id: id} = child_profile
    } do
      conn = put(conn, ~p"/api/child_profiles/#{child_profile}", child_profile: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/child_profiles/#{id}")

      assert %{
               "id" => ^id,
               "age" => 7,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, child_profile: child_profile} do
      conn = put(conn, ~p"/api/child_profiles/#{child_profile}", child_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete child_profile" do
    setup [:create_child_profile]

    test "deletes chosen child_profile", %{conn: conn, child_profile: child_profile} do
      conn = delete(conn, ~p"/api/child_profiles/#{child_profile}")
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/api/child_profiles/#{child_profile}")
      end)
    end
  end

  defp create_child_profile(_) do
    child_profile = child_profile_fixture()

    %{child_profile: child_profile}
  end
end
