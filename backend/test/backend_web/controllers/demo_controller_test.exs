defmodule BackendWeb.DemoControllerTest do
  use BackendWeb.ConnCase

  test "GET /demo shows links to child and parent modes", %{conn: conn} do
    document = conn |> get(~p"/demo") |> document()

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "child-mode-link"), "href") ==
             [~p"/demo/child"]

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "parent-mode-link"), "href") ==
             [~p"/demo/parent"]

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "diagnostic-mode-link"), "href") ==
             [~p"/demo/diagnostic"]

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "content-admin-link"), "href") ==
             [~p"/admin/content"]

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "mobile-api-docs-link"), "href") ==
             [~p"/admin/api-docs"]
  end

  test "GET /demo/child creates demo data and renders the next task", %{conn: conn} do
    document = conn |> get(~p"/demo/child") |> document()

    assert LazyHTML.text(LazyHTML.query_by_id(document, "child-demo-heading")) =~ "Привет, Миша!"

    assert document
           |> LazyHTML.query_by_id("child-demo-question")
           |> LazyHTML.text()
           |> String.trim() == "Где больше яблок?"

    assert Enum.count(LazyHTML.query(document, "#child-answer-form")) == 1
    assert Enum.count(LazyHTML.query(document, "#answer-left")) == 1
    assert Enum.count(LazyHTML.query(document, "#answer-right")) == 1
  end

  test "POST /demo/child/answer renders child-friendly feedback", %{conn: conn} do
    _document = conn |> get(~p"/demo/child") |> document()

    document =
      conn
      |> post(~p"/demo/child/answer", answer: %{selected_answer: "left"})
      |> document()

    feedback = LazyHTML.text(LazyHTML.query_by_id(document, "child-feedback"), separator: " ")

    assert feedback =~ "Почти! Давай посмотрим вместе."
    assert feedback =~ "Подсказка:"
  end

  test "GET /demo/parent shows the parent progress report", %{conn: conn} do
    document = conn |> get(~p"/demo/parent") |> document()

    assert document
           |> LazyHTML.query_by_id("parent-demo-heading")
           |> LazyHTML.text(separator: " ")
           |> String.trim() == "Прогресс ребенка: Миша"

    assert LazyHTML.text(LazyHTML.query(document, "[id^='parent-skill-']")) =~
             "Считает предметы до 10"
  end

  test "GET /demo/diagnostic shows the diagnostic introduction", %{conn: conn} do
    document = conn |> get(~p"/demo/diagnostic") |> document()

    assert Enum.count(LazyHTML.query(document, "#diagnostic-intro")) == 1
    assert Enum.count(LazyHTML.query(document, "#diagnostic-start-form")) == 1
  end

  test "GET curriculum and workbook demos show the product ecosystem", %{conn: conn} do
    curriculum = conn |> get(~p"/demo/curriculum") |> document()
    assert Enum.count(LazyHTML.query(curriculum, "#curriculum-demo-map")) == 1

    workbook = conn |> get(~p"/demo/workbook") |> document()
    assert Enum.count(LazyHTML.query(workbook, "#workbook-demo-pages")) == 1
    assert LazyHTML.text(workbook) =~ "Growly: первые шаги"
  end

  test "POST /demo/diagnostic/start shows the first diagnostic task", %{conn: conn} do
    document = conn |> post(~p"/demo/diagnostic/start") |> document()

    assert Enum.count(LazyHTML.query(document, "#diagnostic-task")) == 1
    assert Enum.count(LazyHTML.query(document, "#diagnostic-answer-form")) == 1
  end

  test "POST /demo/diagnostic/answer advances to the next diagnostic area", %{conn: conn} do
    assert {:ok, demo} = Backend.Demo.ensure_data()

    assert {:ok, %{session: session, task: %{task: task}}} =
             Backend.Learning.start_diagnostic(demo.child.id)

    document =
      conn
      |> post(~p"/demo/diagnostic/answer",
        diagnostic: %{
          session_id: session.id,
          task_id: task.id,
          selected_answer: "right"
        }
      )
      |> document()

    assert Enum.count(LazyHTML.query(document, "#diagnostic-task")) == 1
    assert LazyHTML.text(LazyHTML.query(document, "#diagnostic-task")) =~ "Чтение"
  end

  test "POST /demo/reset clears demo progress and redirects home", %{conn: conn} do
    assert {:ok, demo} = Backend.Demo.ensure_data()

    assert {:ok, _result} =
             Backend.Learning.submit_task_answer(demo.child.id, demo.task.id, %{
               selected_answer: "left"
             })

    conn = post(conn, ~p"/demo/reset")

    assert redirected_to(conn) == ~p"/demo"
    assert Backend.Learning.list_task_attempts() == []
  end

  defp document(conn) do
    conn
    |> html_response(200)
    |> LazyHTML.from_document()
  end
end
