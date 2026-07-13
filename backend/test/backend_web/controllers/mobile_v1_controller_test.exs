defmodule BackendWeb.MobileV1ControllerTest do
  use BackendWeb.ConnCase

  import Backend.ContentFixtures
  import Backend.LearningFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "health returns the mobile API service status", %{conn: conn} do
    assert conn
           |> get(~p"/api/mobile/v1/health")
           |> json_response(200) == %{
             "data" => %{
               "status" => "ok",
               "service" => "growly",
               "version" => "mobile-v1"
             }
           }
  end

  test "pairing session creates an eight-digit code and child-safe QR payload", %{conn: conn} do
    child = child_profile_fixture(%{name: "Миша", age: 6})

    data =
      conn
      |> post(~p"/api/mobile/v1/children/#{child.id}/pairing_sessions")
      |> json_response(201)
      |> Map.fetch!("data")

    assert data["child"] == %{"id" => child.id, "name" => "Миша", "age" => 6}
    assert data["pairing"]["code"] =~ ~r/^\d{8}$/
    assert String.starts_with?(data["pairing"]["qr_payload"], "growly://pair?token=")
    assert data["pairing"]["token"] != ""
    refute inspect(data) =~ "correct_answer"
  end

  test "pairing claim works by code and token", %{conn: conn} do
    code_child = child_profile_fixture(%{age: 6})

    code_pairing =
      conn
      |> post(~p"/api/mobile/v1/children/#{code_child.id}/pairing_sessions")
      |> json_response(201)
      |> get_in(["data", "pairing"])

    code_claim =
      conn
      |> post(~p"/api/mobile/v1/pairing_sessions/claim", %{code: code_pairing["code"]})
      |> json_response(200)
      |> Map.fetch!("data")

    assert code_claim["child"]["id"] == code_child.id
    assert code_claim["links"]["progress"] == "/api/mobile/v1/children/#{code_child.id}/progress"

    token_child = child_profile_fixture(%{age: 6})

    token_pairing =
      conn
      |> post(~p"/api/mobile/v1/children/#{token_child.id}/pairing_sessions")
      |> json_response(201)
      |> get_in(["data", "pairing"])

    token_claim =
      conn
      |> post(~p"/api/mobile/v1/pairing_sessions/claim", %{token: token_pairing["token"]})
      |> json_response(200)
      |> Map.fetch!("data")

    assert token_claim["child"]["id"] == token_child.id
  end

  test "expired and invalid pairing codes fail safely", %{conn: conn} do
    child = child_profile_fixture(%{age: 6})

    pairing =
      conn
      |> post(~p"/api/mobile/v1/children/#{child.id}/pairing_sessions")
      |> json_response(201)
      |> get_in(["data", "pairing"])

    assert {:ok, pairing_session} = Backend.Learning.get_pairing_session_by_code(pairing["code"])

    pairing_session
    |> Ecto.Changeset.change(
      expires_at: DateTime.utc_now() |> DateTime.add(-1, :second) |> DateTime.truncate(:second)
    )
    |> Backend.Repo.update!()

    conn
    |> post(~p"/api/mobile/v1/pairing_sessions/claim", %{code: pairing["code"]})
    |> json_response(422)
    |> get_in(["errors", "pairing"])
    |> then(&assert(&1 == ["code expired"]))

    conn
    |> post(~p"/api/mobile/v1/pairing_sessions/claim", %{code: "12345678"})
    |> json_response(404)
    |> get_in(["errors", "pairing"])
    |> then(&assert(&1 == ["code not found"]))
  end

  test "demo bootstrap creates stable data and returns child links without resetting progress", %{
    conn: conn
  } do
    first =
      conn
      |> get(~p"/api/mobile/v1/demo/bootstrap")
      |> json_response(200)
      |> Map.fetch!("data")

    child_id = first["child"]["id"]
    assert first["parent"]["email"] == "demo-parent@growly.local"
    assert first["child"]["age"] == 6
    assert first["links"]["session"] == "/api/mobile/v1/children/#{child_id}/session"
    assert first["links"]["progress"] == "/api/mobile/v1/children/#{child_id}/progress"
    assert first["links"]["lesson_map"] == "/api/mobile/v1/children/#{child_id}/lesson_map"
    refute inspect(first) =~ "correct_answer"

    session =
      conn
      |> get(~p"/api/mobile/v1/children/#{child_id}/session")
      |> json_response(200)
      |> Map.fetch!("data")

    task_id = session["next_task"]["id"]
    _answer = submit_answer(conn, child_id, task_id, "not-the-correct-answer")

    second =
      conn
      |> get(~p"/api/mobile/v1/demo/bootstrap")
      |> json_response(200)
      |> Map.fetch!("data")

    assert second["child"]["id"] == child_id

    progress =
      conn
      |> get(~p"/api/mobile/v1/children/#{child_id}/progress")
      |> json_response(200)
      |> Map.fetch!("data")

    assert Enum.sum_by(progress["skills"], & &1["incorrect_attempts_count"]) == 1
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

  test "drag count task is graded on the backend without exposing its answer key", %{conn: conn} do
    child = child_profile_fixture(%{age: 6})
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})

    task =
      task_fixture(%{
        skill: skill,
        type: "drag_count_to_baskets",
        options: %{"item" => "apple", "total" => 5},
        correct_answer: "left=2;right=3"
      })

    session =
      conn
      |> get(~p"/api/mobile/v1/children/#{child.id}/session")
      |> json_response(200)
      |> Map.fetch!("data")

    assert session["next_task"]["id"] == task.id
    refute Map.has_key?(session["next_task"], "correct_answer")

    answer = submit_answer(conn, child.id, task.id, "left=2;right=3")
    assert answer["task_attempt"]["is_correct"] == true
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

  test "catalog returns only published courses with curriculum counts", %{conn: conn} do
    published = curriculum_fixture(%{is_published: true})
    _draft = curriculum_fixture(%{slug: "draft-course", is_published: false})

    data = conn |> get(~p"/api/mobile/v1/catalog") |> json_response(200) |> Map.fetch!("data")

    assert [%{"id" => id, "units_count" => 1, "lessons_count" => 1}] = data["courses"]
    assert id == published.course.id
  end

  test "course and lesson payloads never expose correct_answer", %{conn: conn} do
    curriculum = curriculum_fixture()

    course_json =
      conn
      |> get(~p"/api/mobile/v1/courses/#{curriculum.course.id}/map")
      |> json_response(200)

    refute inspect(course_json) =~ "correct_answer"

    lesson_json =
      conn
      |> get(~p"/api/mobile/v1/lessons/#{curriculum.lesson.id}")
      |> json_response(200)

    assert hd(lesson_json["data"]["tasks"])["id"] == curriculum.task.id
    refute inspect(lesson_json) =~ "correct_answer"
    refute inspect(lesson_json) =~ curriculum.task.correct_answer
  end

  test "child lesson map changes from available to completed", %{conn: conn} do
    child = child_profile_fixture(%{age: 6})
    curriculum = curriculum_fixture()

    available =
      conn
      |> get(~p"/api/mobile/v1/children/#{child.id}/lesson_map")
      |> json_response(200)

    lesson = available["data"]["units"] |> hd() |> Map.fetch!("lessons") |> hd()
    assert lesson["status"] == "available"

    assert {:ok, _result} =
             Backend.Learning.submit_task_answer(child.id, curriculum.task.id, %{
               selected_answer: "right"
             })

    completed =
      conn
      |> get(~p"/api/mobile/v1/children/#{child.id}/lesson_map")
      |> json_response(200)

    lesson = completed["data"]["units"] |> hd() |> Map.fetch!("lessons") |> hd()
    assert lesson["status"] == "completed"
    assert lesson["completion_percentage"] == 100
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

  defp curriculum_fixture(overrides \\ %{}) do
    unique = System.unique_integer([:positive])

    {:ok, course} =
      Backend.Content.create_course(%{
        title: "Курс #{unique}",
        slug: Map.get(overrides, :slug, "course-#{unique}"),
        description: "Описание",
        age_min: 5,
        age_max: 7,
        is_published: Map.get(overrides, :is_published, true),
        sort_order: 1
      })

    {:ok, unit} =
      Backend.Content.create_unit(%{
        course_id: course.id,
        title: "Счёт",
        slug: "math",
        description: "Счёт",
        area: "math",
        sort_order: 1
      })

    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})

    {:ok, lesson} =
      Backend.Content.create_lesson(%{
        unit_id: unit.id,
        skill_id: skill.id,
        title: "Считаем",
        slug: "count",
        objective: "Считать",
        explanation: "По одному",
        sort_order: 1,
        is_published: true
      })

    task = task_fixture(%{skill: skill, lesson_id: lesson.id, correct_answer: "right"})
    %{course: course, unit: unit, lesson: lesson, task: task}
  end
end
