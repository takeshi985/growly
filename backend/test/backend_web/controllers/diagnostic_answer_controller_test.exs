defmodule BackendWeb.DiagnosticAnswerControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "evaluates an answer and returns the next diagnostic task", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})
    math_task = diagnostic_task_fixture("math", "right")
    reading_task = diagnostic_task_fixture("reading", "yes")

    assert {:ok, %{session: session}} = Backend.Learning.start_diagnostic(child_profile.id)

    conn =
      post(conn, ~p"/api/diagnostic_sessions/#{session.id}/answers",
        task_id: math_task.id,
        answer: %{selected_answer: "right"}
      )

    assert %{
             "completed" => false,
             "answer" => %{"is_correct" => true, "position" => 1, "task_id" => task_id},
             "next_task" => %{"id" => next_task_id, "area" => "reading"}
           } = json_response(conn, 200)["data"]

    assert task_id == math_task.id
    assert next_task_id == reading_task.id
  end

  defp diagnostic_task_fixture(area, correct_answer) do
    skill = skill_fixture(%{area: area, age_min: 5, age_max: 7})
    task_fixture(%{skill: skill, correct_answer: correct_answer, difficulty: 1})
  end
end
