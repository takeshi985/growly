defmodule BackendWeb.Admin.CurriculumController do
  use BackendWeb, :controller

  alias Backend.Content
  alias Backend.Content.Course
  alias Backend.Content.Lesson
  alias Backend.Content.Unit
  alias Backend.Content.Workbook
  alias Backend.Content.WorkbookPage

  def courses(conn, _params), do: render_index(conn, :course, Content.list_courses())

  def new_course(conn, _params),
    do: render_editor(conn, :course, %Course{}, Content.change_course(%Course{}))

  def create_course(conn, %{"course" => attrs}),
    do: save_new(conn, :course, Content.create_course(attrs))

  def edit_course(conn, %{"id" => id}), do: edit(conn, :course, Content.get_course!(id))

  def update_course(conn, %{"id" => id, "course" => attrs}),
    do:
      save_existing(
        conn,
        :course,
        Content.update_course(Content.get_course!(id), attrs),
        Content.get_course!(id)
      )

  def delete_course(conn, %{"id" => id}),
    do: remove(conn, :course, Content.delete_course(Content.get_course!(id)))

  def units(conn, _params), do: render_index(conn, :unit, Content.list_units())

  def new_unit(conn, _params),
    do: render_editor(conn, :unit, %Unit{}, Content.change_unit(%Unit{}))

  def create_unit(conn, %{"unit" => attrs}), do: save_new(conn, :unit, Content.create_unit(attrs))
  def edit_unit(conn, %{"id" => id}), do: edit(conn, :unit, Content.get_unit!(id))

  def update_unit(conn, %{"id" => id, "unit" => attrs}),
    do:
      save_existing(
        conn,
        :unit,
        Content.update_unit(Content.get_unit!(id), attrs),
        Content.get_unit!(id)
      )

  def delete_unit(conn, %{"id" => id}),
    do: remove(conn, :unit, Content.delete_unit(Content.get_unit!(id)))

  def lessons(conn, _params), do: render_index(conn, :lesson, Content.list_lessons())

  def new_lesson(conn, _params),
    do: render_editor(conn, :lesson, %Lesson{}, Content.change_lesson(%Lesson{}))

  def create_lesson(conn, %{"lesson" => attrs}),
    do: save_new(conn, :lesson, Content.create_lesson(empty_to_nil(attrs, "skill_id")))

  def edit_lesson(conn, %{"id" => id}), do: edit(conn, :lesson, Content.get_lesson!(id))

  def update_lesson(conn, %{"id" => id, "lesson" => attrs}),
    do:
      save_existing(
        conn,
        :lesson,
        Content.update_lesson(Content.get_lesson!(id), empty_to_nil(attrs, "skill_id")),
        Content.get_lesson!(id)
      )

  def delete_lesson(conn, %{"id" => id}),
    do: remove(conn, :lesson, Content.delete_lesson(Content.get_lesson!(id)))

  def workbooks(conn, _params), do: render_index(conn, :workbook, Content.list_workbooks())

  def new_workbook(conn, _params),
    do: render_editor(conn, :workbook, %Workbook{}, Content.change_workbook(%Workbook{}))

  def create_workbook(conn, %{"workbook" => attrs}),
    do: save_new(conn, :workbook, Content.create_workbook(attrs))

  def edit_workbook(conn, %{"id" => id}), do: edit(conn, :workbook, Content.get_workbook!(id))

  def update_workbook(conn, %{"id" => id, "workbook" => attrs}),
    do:
      save_existing(
        conn,
        :workbook,
        Content.update_workbook(Content.get_workbook!(id), attrs),
        Content.get_workbook!(id)
      )

  def delete_workbook(conn, %{"id" => id}),
    do: remove(conn, :workbook, Content.delete_workbook(Content.get_workbook!(id)))

  def workbook_pages(conn, _params),
    do: render_index(conn, :workbook_page, Content.list_workbook_pages())

  def new_workbook_page(conn, _params),
    do:
      render_editor(
        conn,
        :workbook_page,
        %WorkbookPage{},
        Content.change_workbook_page(%WorkbookPage{})
      )

  def create_workbook_page(conn, %{"workbook_page" => attrs}),
    do:
      save_new(
        conn,
        :workbook_page,
        Content.create_workbook_page(empty_to_nil(attrs, "lesson_id"))
      )

  def edit_workbook_page(conn, %{"id" => id}),
    do: edit(conn, :workbook_page, Content.get_workbook_page!(id))

  def update_workbook_page(conn, %{"id" => id, "workbook_page" => attrs}),
    do:
      save_existing(
        conn,
        :workbook_page,
        Content.update_workbook_page(
          Content.get_workbook_page!(id),
          empty_to_nil(attrs, "lesson_id")
        ),
        Content.get_workbook_page!(id)
      )

  def delete_workbook_page(conn, %{"id" => id}),
    do: remove(conn, :workbook_page, Content.delete_workbook_page(Content.get_workbook_page!(id)))

  def export(conn, _params), do: json(conn, %{data: Content.export_content_pack()})

  defp edit(conn, resource, record),
    do: render_editor(conn, resource, record, change(resource, record))

  defp save_new(conn, resource, {:ok, _record}) do
    conn |> put_flash(:info, "#{label(resource)} создан") |> redirect(to: index_path(resource))
  end

  defp save_new(conn, resource, {:error, changeset}) do
    record = struct_for(resource)
    conn |> put_status(:unprocessable_entity) |> render_editor(resource, record, changeset)
  end

  defp save_existing(conn, resource, {:ok, _record}, _original) do
    conn |> put_flash(:info, "#{label(resource)} сохранён") |> redirect(to: index_path(resource))
  end

  defp save_existing(conn, resource, {:error, changeset}, original) do
    conn |> put_status(:unprocessable_entity) |> render_editor(resource, original, changeset)
  end

  defp remove(conn, resource, {:ok, _record}) do
    conn |> put_flash(:info, "#{label(resource)} удалён") |> redirect(to: index_path(resource))
  end

  defp render_index(conn, resource, records) do
    render(conn, :index,
      resource: resource,
      records: records,
      delete_form: Phoenix.Component.to_form(%{}, as: :delete)
    )
  end

  defp render_editor(conn, resource, record, changeset) do
    render(conn, :editor,
      resource: resource,
      record: record,
      form: Phoenix.Component.to_form(changeset),
      courses: Enum.map(Content.list_courses(), &{&1.title, &1.id}),
      units: Enum.map(Content.list_units(), &{"#{&1.course.title} · #{&1.title}", &1.id}),
      skills: Enum.map(Content.list_skills(), &{"#{&1.area} · #{&1.title}", &1.id}),
      lessons: Enum.map(Content.list_lessons(), &{"#{&1.unit.title} · #{&1.title}", &1.id}),
      workbooks: Enum.map(Content.list_workbooks(), &{&1.title, &1.id})
    )
  end

  defp change(:course, record), do: Content.change_course(record)
  defp change(:unit, record), do: Content.change_unit(record)
  defp change(:lesson, record), do: Content.change_lesson(record)
  defp change(:workbook, record), do: Content.change_workbook(record)
  defp change(:workbook_page, record), do: Content.change_workbook_page(record)

  defp struct_for(:course), do: %Course{}
  defp struct_for(:unit), do: %Unit{}
  defp struct_for(:lesson), do: %Lesson{}
  defp struct_for(:workbook), do: %Workbook{}
  defp struct_for(:workbook_page), do: %WorkbookPage{}

  defp index_path(:course), do: ~p"/admin/content/courses"
  defp index_path(:unit), do: ~p"/admin/content/units"
  defp index_path(:lesson), do: ~p"/admin/content/lessons"
  defp index_path(:workbook), do: ~p"/admin/content/workbooks"
  defp index_path(:workbook_page), do: ~p"/admin/content/workbook_pages"

  defp label(:course), do: "Курс"
  defp label(:unit), do: "Раздел"
  defp label(:lesson), do: "Урок"
  defp label(:workbook), do: "Тетрадь"
  defp label(:workbook_page), do: "Страница"

  defp empty_to_nil(attrs, key),
    do: if(attrs[key] == "", do: Map.put(attrs, key, nil), else: attrs)
end
