defmodule BackendWeb.ChildNextTaskControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "renders next task without exposing correct_answer", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, correct_answer: "right"})

    conn = get(conn, ~p"/api/children/#{child_profile.id}/next_task")

    assert %{
             "id" => task_id,
             "skill_id" => skill_id,
             "type" => "some type",
             "question" => "some question",
             "options" => %{},
             "difficulty" => 42,
             "hint1" => "some hint1",
             "hint2" => "some hint2",
             "explanation" => "some explanation"
           } = json_response(conn, 200)["data"]

    assert task_id == task.id
    assert skill_id == skill.id
    refute Map.has_key?(json_response(conn, 200)["data"], "correct_answer")
  end

  test "renders 404 when child profile does not exist", %{conn: conn} do
    conn = get(conn, ~p"/api/children/-1/next_task")

    assert %{"errors" => %{"child_id" => ["does not exist"]}} = json_response(conn, 404)
  end

  test "renders 404 when no task is available", %{conn: conn} do
    child_profile = child_profile_fixture(%{age: 6})

    conn = get(conn, ~p"/api/children/#{child_profile.id}/next_task")

    assert %{"errors" => %{"task" => ["no task available"]}} = json_response(conn, 404)
  end
end
