defmodule Backend.ContentCurriculumTest do
  use Backend.DataCase

  alias Backend.Content
  alias Backend.Content.Course
  alias Backend.Content.Lesson
  alias Backend.Content.Unit
  alias Backend.Content.Workbook
  alias Backend.Content.WorkbookPage

  import Backend.ContentFixtures

  test "creates and updates a course, unit, and lesson" do
    assert {:ok, %Course{} = course} = Content.create_course(course_attrs())
    assert {:ok, %Unit{} = unit} = Content.create_unit(unit_attrs(course.id))
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})

    assert {:ok, %Lesson{} = lesson} =
             Content.create_lesson(lesson_attrs(unit.id, skill.id))

    assert Content.list_units_for_course(course.id) == [unit]
    assert Content.list_lessons_for_unit(unit.id) == [lesson]

    assert {:ok, updated_course} = Content.update_course(course, %{title: "Новый курс"})
    assert updated_course.title == "Новый курс"

    assert {:ok, updated_unit} = Content.update_unit(unit, %{title: "Новый раздел"})
    assert updated_unit.title == "Новый раздел"

    assert {:ok, updated_lesson} = Content.update_lesson(lesson, %{title: "Новый урок"})
    assert updated_lesson.title == "Новый урок"
  end

  test "published catalog excludes draft courses" do
    assert {:ok, published} = Content.create_course(course_attrs())

    assert {:ok, _draft} =
             Content.create_course(course_attrs(%{slug: "draft", is_published: false}))

    assert Enum.map(Content.list_published_courses(), & &1.id) == [published.id]
  end

  test "creates workbooks and generates unique QR tokens for pages" do
    assert {:ok, %Workbook{} = workbook} = Content.create_workbook(workbook_attrs())

    assert {:ok, %WorkbookPage{} = first} =
             Content.create_workbook_page(page_attrs(workbook.id, 1))

    assert {:ok, %WorkbookPage{} = second} =
             Content.create_workbook_page(page_attrs(workbook.id, 2))

    assert is_binary(first.qr_code_token)
    assert byte_size(first.qr_code_token) >= 12
    refute first.qr_code_token == second.qr_code_token
    assert {:ok, found} = Content.get_workbook_page_by_token(first.qr_code_token)
    assert found.id == first.id
  end

  defp course_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        title: "Подготовка к школе",
        slug: "school-readiness",
        description: "Описание курса",
        age_min: 5,
        age_max: 7,
        is_published: true,
        sort_order: 1
      },
      overrides
    )
  end

  defp unit_attrs(course_id) do
    %{
      course_id: course_id,
      title: "Счёт",
      slug: "math",
      description: "Математика",
      area: "math",
      sort_order: 1
    }
  end

  defp lesson_attrs(unit_id, skill_id) do
    %{
      unit_id: unit_id,
      skill_id: skill_id,
      title: "Считаем",
      slug: "count",
      objective: "Научиться считать",
      explanation: "Считаем по одному",
      sort_order: 1,
      is_published: true
    }
  end

  defp workbook_attrs do
    %{
      title: "Первые шаги",
      slug: "first-steps",
      description: "Тетрадь",
      age_min: 5,
      age_max: 7,
      is_published: true,
      sort_order: 1
    }
  end

  defp page_attrs(workbook_id, page_number) do
    %{
      workbook_id: workbook_id,
      title: "Страница #{page_number}",
      page_number: page_number,
      instructions: "Выполни задание",
      qr_target_type: "lesson",
      is_published: true
    }
  end
end
