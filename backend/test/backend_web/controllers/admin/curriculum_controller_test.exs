defmodule BackendWeb.Admin.CurriculumControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Content

  test "curriculum and workbook admin index pages return 200", %{conn: conn} do
    for path <- [
          ~p"/admin/content/courses",
          ~p"/admin/content/units",
          ~p"/admin/content/lessons",
          ~p"/admin/content/workbooks",
          ~p"/admin/content/workbook_pages"
        ] do
      assert html_response(get(conn, path), 200) =~ "Internal MVP only"
    end
  end

  test "creates and updates course, unit, and lesson through admin", %{conn: conn} do
    course_conn = post(conn, ~p"/admin/content/courses", course: course_attrs())
    assert redirected_to(course_conn) == ~p"/admin/content/courses"
    course = hd(Content.list_courses())

    unit_conn = post(conn, ~p"/admin/content/units", unit: unit_attrs(course.id))
    assert redirected_to(unit_conn) == ~p"/admin/content/units"
    unit = hd(Content.list_units_for_course(course.id))

    lesson_conn = post(conn, ~p"/admin/content/lessons", lesson: lesson_attrs(unit.id))
    assert redirected_to(lesson_conn) == ~p"/admin/content/lessons"
    lesson = hd(Content.list_lessons_for_unit(unit.id))

    update_conn =
      patch(conn, ~p"/admin/content/lessons/#{lesson}",
        lesson: Map.put(lesson_attrs(unit.id), :title, "Обновлённый урок")
      )

    assert redirected_to(update_conn) == ~p"/admin/content/lessons"
    assert Content.get_lesson!(lesson.id).title == "Обновлённый урок"
  end

  test "creates workbook page with generated QR token and exports content", %{conn: conn} do
    workbook_conn = post(conn, ~p"/admin/content/workbooks", workbook: workbook_attrs())
    assert redirected_to(workbook_conn) == ~p"/admin/content/workbooks"
    workbook = hd(Content.list_workbooks())

    page_conn =
      post(conn, ~p"/admin/content/workbook_pages",
        workbook_page: %{
          workbook_id: workbook.id,
          lesson_id: "",
          title: "Первая страница",
          page_number: 1,
          instructions: "Выполни задание",
          qr_code_token: "",
          qr_target_type: "lesson",
          qr_target_id: "",
          is_published: true
        }
      )

    assert redirected_to(page_conn) == ~p"/admin/content/workbook_pages"
    [page] = Content.list_workbook_pages()
    assert is_binary(page.qr_code_token)

    export = conn |> get(~p"/admin/content/export") |> json_response(200)
    assert export["data"]["version"] == 1
    assert length(export["data"]["workbooks"]) == 1
  end

  defp course_attrs do
    %{
      title: "Подготовка",
      slug: "prep",
      description: "Описание",
      age_min: 5,
      age_max: 7,
      is_published: true,
      sort_order: 1
    }
  end

  defp unit_attrs(course_id) do
    %{
      course_id: course_id,
      title: "Счёт",
      slug: "math",
      description: "Счёт",
      area: "math",
      sort_order: 1
    }
  end

  defp lesson_attrs(unit_id) do
    %{
      unit_id: unit_id,
      skill_id: "",
      title: "Считаем",
      slug: "count",
      objective: "Считать",
      explanation: "По одному",
      sort_order: 1,
      is_published: true
    }
  end

  defp workbook_attrs do
    %{
      title: "Тетрадь",
      slug: "workbook",
      description: "Описание",
      age_min: 5,
      age_max: 7,
      is_published: true,
      sort_order: 1
    }
  end
end
