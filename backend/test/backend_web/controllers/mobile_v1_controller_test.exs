defmodule BackendWeb.MobileV1ControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "session returns child, progress, and a child-safe next task", %{conn: conn} do
    child = child_profile_fixture(%{name: "Миша", age: 6})
    skill = skill_fixture(%{title: "Считает предметы", area: "math", age_min: 5, age_max: 7})

    task =
      task_fixture(%{
        skill: skill,
        question: "Где больше?",
        correct_answer: "right",
        hint1: "Первая подсказка",
        hint2: "Вторая подсказка",
        explanation: "Объяснение"
      })

    data =
      conn
      |> get(~p"/api/mobile/v1/children/#{child.id}/session")
      |> json_response(200)
      |> Map.fetch!("data")

    assert data["child"] == %{"id" => child.id, "name" => "Миша", "age" => 6}
    assert data["session_state"]["has_next_task"] == true
    assert data["next_task"]["id"] == task.id
    assert data["next_task"]["skill_title"] == skill.title
    assert data["next_task"]["area"] == "math"
    refute Map.has_key?(data["next_task"], "correct_answer")
    refute Map.has_key?(data["next_task"], "hint1")
    refute Map.has_key?(data["next_task"], "hint2")
    refute Map.has_key?(data["next_task"], "explanation")
  end

  test "answer is backend-graded and refreshes next task and progress", %{conn: conn} do
    child = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, correct_answer: "right", difficulty: 1})
    next_task = task_fixture(%{skill: skill, difficulty: 2})

    data = submit_answer(conn, child.id, task.id, "right")

    assert data["task_attempt"]["is_correct"] == true
    assert data["task_attempt"]["attempt_number"] == 1
    assert data["feedback"]["action"] == "continue"
    assert data["next_task"]["id"] == next_task.id
    assert data["progress_summary"]["completed_tasks"] == 1
    assert data["progress_summary"]["completion_percentage"] == 50
  end

  test "three wrong answers return hint1, hint2, then review_later and move forward", %{
    conn: conn
  } do
    child = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{area: "logic", age_min: 5, age_max: 7})

    task =
      task_fixture(%{
        skill: skill,
        correct_answer: "right",
        difficulty: 1,
        hint1: "Посчитай ещё раз",
        hint2: "Справа пять",
        explanation: "Пять больше трёх"
      })

    next_task = task_fixture(%{skill: skill, difficulty: 2})

    first = submit_answer(conn, child.id, task.id, "left")
    assert first["feedback"]["action"] == "show_hint1"
    assert first["feedback"]["hint"] == "Посчитай ещё раз"
    assert first["next_task"]["id"] == task.id

    second = submit_answer(conn, child.id, task.id, "left")
    assert second["feedback"]["action"] == "show_hint2"
    assert second["feedback"]["hint"] == "Справа пять"

    third = submit_answer(conn, child.id, task.id, "left")
    assert third["feedback"]["action"] == "review_later"
    assert third["feedback"]["explanation"] == "Пять больше трёх"
    assert third["next_task"]["id"] == next_task.id
    assert third["progress_summary"]["skills_needing_review"] == 1
  end

  test "mobile progress exposes consistent status labels and recommendation priority", %{
    conn: conn
  } do
    child = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{area: "reading", age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, correct_answer: "yes"})

    for _attempt <- 1..3, do: submit_answer(conn, child.id, task.id, "no")

    data =
      conn
      |> get(~p"/api/mobile/v1/children/#{child.id}/progress")
      |> json_response(200)
      |> Map.fetch!("data")

    [skill_progress] = data["skills"]
    assert skill_progress["status"] == "needs_review"
    assert skill_progress["status_label"] == "Нужно повторить"
    assert skill_progress["area_label"] == "Чтение"
    assert skill_progress["recommendation_priority"] == "high"
    assert hd(data["recommendations"])["priority"] == "high"
  end

  test "mobile diagnostic is child-safe and returns a starting recommendation", %{conn: conn} do
    child = child_profile_fixture(%{age: 6})
    math_task = diagnostic_task_fixture("math", "right")
    reading_task = diagnostic_task_fixture("reading", "yes")
    logic_task = diagnostic_task_fixture("logic", "blue")

    started =
      conn
      |> post(~p"/api/mobile/v1/children/#{child.id}/diagnostic/start")
      |> json_response(201)
      |> Map.fetch!("data")

    refute Map.has_key?(started["task"], "correct_answer")
    session_id = started["session"]["id"]

    first = diagnostic_answer(conn, session_id, math_task.id, "left")
    second = diagnostic_answer(conn, session_id, reading_task.id, "yes")
    final = diagnostic_answer(conn, session_id, logic_task.id, "blue")

    assert first["completed"] == false
    assert second["completed"] == false
    assert final["completed"] == true
    assert final["result"]["recommended_starting_area"] == "math"
    assert final["result"]["areas_needing_basics"] == 1
    assert hd(final["result"]["recommended_focus"])["area_label"] == "Счёт"
  end

  defp submit_answer(conn, child_id, task_id, selected_answer) do
    conn
    |> post(~p"/api/mobile/v1/children/#{child_id}/tasks/#{task_id}/answer",
      answer: %{selected_answer: selected_answer, hint_used: false}
    )
    |> json_response(200)
    |> Map.fetch!("data")
  end

  defp diagnostic_answer(conn, session_id, task_id, selected_answer) do
    conn
    |> post(~p"/api/mobile/v1/diagnostic_sessions/#{session_id}/tasks/#{task_id}/answer",
      answer: %{selected_answer: selected_answer}
    )
    |> json_response(200)
    |> Map.fetch!("data")
  end

  defp diagnostic_task_fixture(area, correct_answer) do
    skill = skill_fixture(%{area: area, age_min: 5, age_max: 7})
    task_fixture(%{skill: skill, correct_answer: correct_answer, difficulty: 1})
  end
end
