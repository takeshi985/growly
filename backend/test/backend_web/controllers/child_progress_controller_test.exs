defmodule BackendWeb.ChildProgressControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "renders the child progress report for the parent", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{title: "Счет", area: "math", age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, correct_answer: "right"})

    assert {:ok, _task_attempt} =
             Backend.Learning.create_task_attempt(%{
               child_profile_id: child_profile.id,
               task_id: task.id,
               selected_answer: "right",
               hint_used: false
             })

    conn = get(conn, ~p"/api/children/#{child_profile.id}/progress")

    assert %{
             "child" => %{"id" => child_id, "name" => "some name", "age" => 6},
             "summary" => %{
               "completed_tasks" => 1,
               "mastered_skills" => 1,
               "completion_percentage" => 100
             },
             "skills" => [
               %{
                 "id" => skill_id,
                 "status" => "mastered",
                 "completed_tasks" => 1,
                 "total_tasks" => 1
               }
             ],
             "recommendations" => []
           } = json_response(conn, 200)["data"]

    assert child_id == child_profile.id
    assert skill_id == skill.id
  end

  test "renders 404 when the child profile does not exist", %{conn: conn} do
    conn = get(conn, ~p"/api/children/-1/progress")

    assert %{"errors" => %{"child_id" => ["does not exist"]}} = json_response(conn, 404)
  end
end
