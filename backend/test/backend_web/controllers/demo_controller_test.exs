defmodule BackendWeb.DemoControllerTest do
  use BackendWeb.ConnCase

  test "GET /demo shows links to child and parent modes", %{conn: conn} do
    document = conn |> get(~p"/demo") |> document()

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "child-mode-link"), "href") ==
             [~p"/demo/child"]

    assert LazyHTML.attribute(LazyHTML.query_by_id(document, "parent-mode-link"), "href") ==
             [~p"/demo/parent"]
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
             "Счет предметов до 10"
  end

  defp document(conn) do
    conn
    |> html_response(200)
    |> LazyHTML.from_document()
  end
end
