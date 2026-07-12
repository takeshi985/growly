defmodule BackendWeb.DemoControllerTest do
  use BackendWeb.ConnCase

  test "GET /demo shows links to child and parent modes", %{conn: conn} do
    conn = get(conn, ~p"/demo")

    assert html_response(conn, 200) =~ "Режим ребенка"
    assert html_response(conn, 200) =~ ~p"/demo/child"
    assert html_response(conn, 200) =~ ~p"/demo/parent"
  end

  test "GET /demo/child creates demo data and renders the next task", %{conn: conn} do
    conn = get(conn, ~p"/demo/child")

    assert html_response(conn, 200) =~ "Привет, Миша!"
    assert html_response(conn, 200) =~ "Где больше яблок?"
    assert html_response(conn, 200) =~ "Проверить ответ"
  end

  test "POST /demo/child/answer renders child-friendly feedback", %{conn: conn} do
    conn = get(conn, ~p"/demo/child")

    conn = post(conn, ~p"/demo/child/answer", answer: %{selected_answer: "left"})

    assert html_response(conn, 200) =~ "Почти! Давай посмотрим вместе."
    assert html_response(conn, 200) =~ "Подсказка:"
  end

  test "GET /demo/parent shows the parent progress report", %{conn: conn} do
    conn = get(conn, ~p"/demo/parent")

    assert html_response(conn, 200) =~ "Прогресс Миши"
    assert html_response(conn, 200) =~ "Счет предметов до 10"
  end
end
