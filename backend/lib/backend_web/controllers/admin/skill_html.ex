defmodule BackendWeb.Admin.SkillHTML do
  use BackendWeb, :html

  embed_templates "skill_html/*"

  def area_label("math"), do: "Счёт"
  def area_label("reading"), do: "Чтение"
  def area_label("logic"), do: "Логика"
  def area_label(area), do: area

  def area_options do
    [{"Счёт", "math"}, {"Чтение", "reading"}, {"Логика", "logic"}]
  end
end
