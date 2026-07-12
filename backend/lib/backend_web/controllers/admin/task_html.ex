defmodule BackendWeb.Admin.TaskHTML do
  use BackendWeb, :html

  embed_templates "task_html/*"

  def area_label("math"), do: "Счёт"
  def area_label("reading"), do: "Чтение"
  def area_label("logic"), do: "Логика"
  def area_label(area), do: area

  def type_options do
    [
      {"Один вариант ответа", "multiple_choice"},
      {"Выбор стороны", "choose_side"},
      {"Выбор изображения", "image_choice"}
    ]
  end
end
