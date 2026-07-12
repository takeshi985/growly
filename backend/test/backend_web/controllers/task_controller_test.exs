defmodule BackendWeb.TaskControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  alias Backend.Content.Task

  @create_attrs %{
    type: "some type",
    options: %{},
    question: "some question",
    correct_answer: "some correct_answer",
    difficulty: 42,
    hint1: "some hint1",
    hint2: "some hint2",
    explanation: "some explanation",
    skill_id: nil
  }
  @update_attrs %{
    type: "some updated type",
    options: %{},
    question: "some updated question",
    correct_answer: "some updated correct_answer",
    difficulty: 43,
    hint1: "some updated hint1",
    hint2: "some updated hint2",
    explanation: "some updated explanation"
  }
  @invalid_attrs %{
    type: nil,
    options: nil,
    question: nil,
    correct_answer: nil,
    difficulty: nil,
    hint1: nil,
    hint2: nil,
    explanation: nil,
    skill_id: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get(conn, ~p"/api/tasks")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task" do
    test "renders task when data is valid", %{conn: conn} do
      skill = skill_fixture()
      create_attrs = %{@create_attrs | skill_id: skill.id}

      conn = post(conn, ~p"/api/tasks", task: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "correct_answer" => "some correct_answer",
               "difficulty" => 42,
               "explanation" => "some explanation",
               "hint1" => "some hint1",
               "hint2" => "some hint2",
               "options" => %{},
               "question" => "some question",
               "skill_id" => skill_id,
               "type" => "some type"
             } = json_response(conn, 200)["data"]

      assert skill_id == skill.id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "correct_answer" => "some updated correct_answer",
               "difficulty" => 43,
               "explanation" => "some updated explanation",
               "hint1" => "some updated hint1",
               "hint2" => "some updated hint2",
               "options" => %{},
               "question" => "some updated question",
               "type" => "some updated type"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/api/tasks/#{task}")
      end)
    end
  end

  defp create_task(_) do
    task = task_fixture()

    %{task: task}
  end
end
