defmodule BackendWeb.ChildTaskAnswerControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "grades an answer and returns the first gentle hint", %{conn: conn} do
    child_profile = child_profile_fixture()

    task =
      task_fixture(%{
        correct_answer: "right",
        hint1: "Посчитай предметы по очереди."
      })

    conn =
      post(conn, ~p"/api/children/#{child_profile.id}/tasks/#{task.id}/answer",
        answer: %{selected_answer: "left", hint_used: false}
      )

    assert %{
             "attempt" => %{
               "attempt_number" => 1,
               "is_correct" => false,
               "selected_answer" => "left",
               "task_id" => task_id
             },
             "feedback" => %{
               "action" => "show_hint1",
               "can_continue" => true,
               "hint" => "Посчитай предметы по очереди.",
               "result" => "incorrect"
             }
           } = json_response(conn, 201)["data"]

    assert task_id == task.id
  end

  test "returns review_later after the third wrong answer", %{conn: conn} do
    child_profile = child_profile_fixture()
    task = task_fixture(%{correct_answer: "right", explanation: "5 больше, чем 3."})

    for _ <- 1..2 do
      post(conn, ~p"/api/children/#{child_profile.id}/tasks/#{task.id}/answer",
        answer: %{selected_answer: "left", hint_used: false}
      )
    end

    conn =
      post(conn, ~p"/api/children/#{child_profile.id}/tasks/#{task.id}/answer",
        answer: %{selected_answer: "left", hint_used: false}
      )

    assert %{
             "attempt" => %{"attempt_number" => 3, "is_correct" => false},
             "feedback" => %{
               "action" => "review_later",
               "explanation" => "5 больше, чем 3.",
               "result" => "incorrect"
             }
           } = json_response(conn, 201)["data"]
  end

  test "returns 404 when the child or task does not exist", %{conn: conn} do
    task = task_fixture()

    conn =
      post(conn, ~p"/api/children/-1/tasks/#{task.id}/answer",
        answer: %{selected_answer: "right"}
      )

    assert %{"errors" => %{"child_id" => ["does not exist"]}} = json_response(conn, 404)

    child_profile = child_profile_fixture()

    conn =
      post(conn, ~p"/api/children/#{child_profile.id}/tasks/-1/answer",
        answer: %{selected_answer: "right"}
      )

    assert %{"errors" => %{"task_id" => ["does not exist"]}} = json_response(conn, 404)
  end
end
