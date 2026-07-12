defmodule BackendWeb.SkillControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  alias Backend.Content.Skill

  @create_attrs %{
    title: "some title",
    area: "some area",
    age_min: 42,
    age_max: 42
  }
  @update_attrs %{
    title: "some updated title",
    area: "some updated area",
    age_min: 43,
    age_max: 43
  }
  @invalid_attrs %{title: nil, area: nil, age_min: nil, age_max: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all skills", %{conn: conn} do
      conn = get(conn, ~p"/api/skills")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create skill" do
    test "renders skill when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/skills", skill: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/skills/#{id}")

      assert %{
               "id" => ^id,
               "age_max" => 42,
               "age_min" => 42,
               "area" => "some area",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/skills", skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update skill" do
    setup [:create_skill]

    test "renders skill when data is valid", %{conn: conn, skill: %Skill{id: id} = skill} do
      conn = put(conn, ~p"/api/skills/#{skill}", skill: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/skills/#{id}")

      assert %{
               "id" => ^id,
               "age_max" => 43,
               "age_min" => 43,
               "area" => "some updated area",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, skill: skill} do
      conn = put(conn, ~p"/api/skills/#{skill}", skill: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete skill" do
    setup [:create_skill]

    test "deletes chosen skill", %{conn: conn, skill: skill} do
      conn = delete(conn, ~p"/api/skills/#{skill}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/skills/#{skill}")
      end
    end
  end

  defp create_skill(_) do
    skill = skill_fixture()

    %{skill: skill}
  end
end
