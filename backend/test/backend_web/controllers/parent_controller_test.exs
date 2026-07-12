defmodule BackendWeb.ParentControllerTest do
  use BackendWeb.ConnCase

  import Backend.AccountsFixtures
  alias Backend.Accounts.Parent

  @create_attrs %{
    email: "some email"
  }
  @update_attrs %{
    email: "some updated email"
  }
  @invalid_attrs %{email: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all parents", %{conn: conn} do
      conn = get(conn, ~p"/api/parents")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create parent" do
    test "renders parent when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/parents", parent: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/parents/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/parents", parent: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update parent" do
    setup [:create_parent]

    test "renders parent when data is valid", %{conn: conn, parent: %Parent{id: id} = parent} do
      conn = put(conn, ~p"/api/parents/#{parent}", parent: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/parents/#{id}")

      assert %{
               "id" => ^id,
               "email" => "some updated email"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, parent: parent} do
      conn = put(conn, ~p"/api/parents/#{parent}", parent: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete parent" do
    setup [:create_parent]

    test "deletes chosen parent", %{conn: conn, parent: parent} do
      conn = delete(conn, ~p"/api/parents/#{parent}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/parents/#{parent}")
      end
    end
  end

  defp create_parent(_) do
    parent = parent_fixture()

    %{parent: parent}
  end
end
