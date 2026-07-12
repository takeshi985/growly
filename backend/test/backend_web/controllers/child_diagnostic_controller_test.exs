defmodule BackendWeb.ChildDiagnosticControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "starts a diagnostic session without exposing the correct answer", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, correct_answer: "right"})

    conn = post(conn, ~p"/api/children/#{child_profile.id}/diagnostic_sessions")

    assert %{
             "session" => %{
               "id" => session_id,
               "child_profile_id" => child_id,
               "status" => "in_progress"
             },
             "task" => %{
               "area" => "math",
               "id" => task_id,
               "skill_id" => skill_id,
               "question" => "some question"
             }
           } = json_response(conn, 201)["data"]

    assert session_id
    assert child_id == child_profile.id
    assert task_id == task.id
    assert skill_id == skill.id
    refute Map.has_key?(json_response(conn, 201)["data"]["task"], "correct_answer")
  end

  test "renders an error when there are no age-appropriate diagnostic tasks", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})

    conn = post(conn, ~p"/api/children/#{child_profile.id}/diagnostic_sessions")

    assert %{"errors" => %{"diagnostic" => ["no age-appropriate tasks available"]}} =
             json_response(conn, 422)
  end
end
