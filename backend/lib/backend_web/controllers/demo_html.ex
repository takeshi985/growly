defmodule BackendWeb.DemoHTML do
  use BackendWeb, :html

  embed_templates "demo_html/*"

  def area_label("math"), do: "Математика"
  def area_label("reading"), do: "Чтение"
  def area_label("logic"), do: "Логика"
  def area_label(area), do: area

  def status_label(:mastered), do: "Освоено"
  def status_label(:needs_review), do: "Повторить"
  def status_label(:in_progress), do: "В процессе"
  def status_label(:not_started), do: "Не начато"

  def status_class(:mastered),
    do: "rounded-full bg-emerald-100 px-3 py-1 text-xs font-bold text-emerald-700"

  def status_class(:needs_review),
    do: "rounded-full bg-amber-100 px-3 py-1 text-xs font-bold text-amber-700"

  def status_class(:in_progress),
    do: "rounded-full bg-sky-100 px-3 py-1 text-xs font-bold text-sky-700"

  def status_class(:not_started),
    do: "rounded-full bg-slate-200 px-3 py-1 text-xs font-bold text-slate-600"

  def diagnostic_result_label(:ready_to_continue), do: "Можно продолжать"
  def diagnostic_result_label(:start_from_basics), do: "Начать с основ"

  def diagnostic_result_class(:ready_to_continue),
    do: "rounded-full bg-emerald-100 px-3 py-1 text-xs font-bold text-emerald-700"

  def diagnostic_result_class(:start_from_basics),
    do: "rounded-full bg-amber-100 px-3 py-1 text-xs font-bold text-amber-700"

  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :tone, :string, required: true

  def summary_card(assigns) do
    ~H"""
    <div class={["rounded-2xl border bg-white p-5 shadow-sm", summary_tone(@tone)]}>
      <p class="text-sm font-bold text-slate-500">{@label}</p>
      <p class="mt-2 text-3xl font-black text-slate-900">{@value}</p>
    </div>
    """
  end

  defp summary_tone("violet"), do: "border-violet-100"
  defp summary_tone("emerald"), do: "border-emerald-100"
  defp summary_tone("amber"), do: "border-amber-100"
  defp summary_tone("sky"), do: "border-sky-100"
end
