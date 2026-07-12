defmodule BackendWeb.TaskAttemptControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures
  alias Backend.Learning.TaskAttempt

  @create_attrs %{
    child_profile_id: nil,
    task_id: nil,
    selected_answer: "right",
    hint_used: true
  }
  @update_attrs %{
    selected_answer: "some updated selected_answer",
    is_correct: false,
    hint_used: false,
    attempt_number: 43
  }
  @invalid_attrs %{child_profile_id: nil, task_id: nil, selected_answer: nil, hint_used: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all task_attempts", %{conn: conn} do
      conn = get(conn, ~p"/api/task_attempts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task_attempt" do
    test "renders task_attempt when data is valid", %{conn: conn} do
      child_profile = child_profile_fixture()
      task = task_fixture(%{correct_answer: "right"})
      create_attrs = %{@create_attrs | child_profile_id: child_profile.id, task_id: task.id}

      conn = post(conn, ~p"/api/task_attempts", task_attempt: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/task_attempts/#{id}")

      assert %{
               "id" => ^id,
               "attempt_number" => 1,
               "child_profile_id" => child_profile_id,
               "hint_used" => true,
               "is_correct" => true,
               "selected_answer" => "right",
               "task_id" => task_id
             } = json_response(conn, 200)["data"]

      assert child_profile_id == child_profile.id
      assert task_id == task.id
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/task_attempts", task_attempt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task_attempt" do
    setup [:create_task_attempt]

    test "renders task_attempt when data is valid", %{
      conn: conn,
      task_attempt: %TaskAttempt{id: id} = task_attempt
    } do
      conn = put(conn, ~p"/api/task_attempts/#{task_attempt}", task_attempt: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/task_attempts/#{id}")

      assert %{
               "id" => ^id,
               "attempt_number" => 43,
               "hint_used" => false,
               "is_correct" => false,
               "selected_answer" => "some updated selected_answer"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task_attempt: task_attempt} do
      conn = put(conn, ~p"/api/task_attempts/#{task_attempt}", task_attempt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task_attempt" do
    setup [:create_task_attempt]

    test "deletes chosen task_attempt", %{conn: conn, task_attempt: task_attempt} do
      conn = delete(conn, ~p"/api/task_attempts/#{task_attempt}")
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, ~p"/api/task_attempts/#{task_attempt}")
      end)
    end
  end

  defp create_task_attempt(_) do
    task_attempt = task_attempt_fixture()

    %{task_attempt: task_attempt}
  end
end
