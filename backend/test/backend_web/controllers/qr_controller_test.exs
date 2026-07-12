defmodule BackendWeb.QrControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Content

  test "valid QR token renders a safe workbook landing and invalid token returns 404", %{
    conn: conn
  } do
    {:ok, workbook} =
      Content.create_workbook(%{
        title: "Тетрадь",
        slug: "qr-test",
        description: "Описание",
        age_min: 5,
        age_max: 7,
        is_published: true,
        sort_order: 1
      })

    {:ok, page} =
      Content.create_workbook_page(%{
        workbook_id: workbook.id,
        title: "Первая страница",
        page_number: 1,
        instructions: "Выполни задание",
        qr_target_type: "lesson",
        is_published: true
      })

    document = conn |> get(~p"/qr/#{page.qr_code_token}") |> html_response(200)
    assert document =~ "Первая страница"
    assert document =~ "Открыть демо-задания"

    assert response(get(conn, ~p"/qr/unknown-token"), 404)
  end
end
