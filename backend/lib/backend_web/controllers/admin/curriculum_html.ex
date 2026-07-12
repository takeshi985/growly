defmodule BackendWeb.Admin.CurriculumHTML do
  use BackendWeb, :html

  embed_templates "curriculum_html/*"

  def title(:course), do: "Курсы"
  def title(:unit), do: "Разделы"
  def title(:lesson), do: "Уроки"
  def title(:workbook), do: "Рабочие тетради"
  def title(:workbook_page), do: "Страницы и QR"

  def singular(:course), do: "курс"
  def singular(:unit), do: "раздел"
  def singular(:lesson), do: "урок"
  def singular(:workbook), do: "тетрадь"
  def singular(:workbook_page), do: "страницу"

  def index_path(:course), do: ~p"/admin/content/courses"
  def index_path(:unit), do: ~p"/admin/content/units"
  def index_path(:lesson), do: ~p"/admin/content/lessons"
  def index_path(:workbook), do: ~p"/admin/content/workbooks"
  def index_path(:workbook_page), do: ~p"/admin/content/workbook_pages"

  def new_path(resource), do: index_path(resource) <> "/new"
  def edit_path(resource, record), do: index_path(resource) <> "/#{record.id}/edit"
  def record_path(resource, record), do: index_path(resource) <> "/#{record.id}"

  def record_title(:course, record), do: record.title
  def record_title(:unit, record), do: "#{record.course.title} · #{record.title}"
  def record_title(:lesson, record), do: "#{record.unit.title} · #{record.title}"
  def record_title(:workbook, record), do: record.title

  def record_title(:workbook_page, record),
    do: "#{record.workbook.title} · стр. #{record.page_number}: #{record.title}"

  def record_meta(:course, record),
    do: "#{length(record.units)} разделов · #{published(record.is_published)}"

  def record_meta(:unit, record), do: "#{record.area} · #{length(record.lessons)} уроков"

  def record_meta(:lesson, record),
    do: "#{length(record.tasks)} заданий · #{published(record.is_published)}"

  def record_meta(:workbook, record),
    do: "#{length(record.pages)} страниц · #{published(record.is_published)}"

  def record_meta(:workbook_page, record), do: "/qr/#{record.qr_code_token}"

  defp published(true), do: "опубликовано"
  defp published(false), do: "черновик"
end
