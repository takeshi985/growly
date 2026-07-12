defmodule BackendWeb.Admin.ContentHTML do
  use BackendWeb, :html

  embed_templates "content_html/*"

  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :tone, :string, required: true

  def metric(assigns) do
    ~H"""
    <div class={["rounded-2xl border bg-white p-5 shadow-sm", tone_class(@tone)]}>
      <p class="text-sm font-bold text-slate-500">{@label}</p>
      <p class="mt-2 text-3xl font-black text-slate-900">{@value}</p>
    </div>
    """
  end

  defp tone_class("violet"), do: "border-violet-100"
  defp tone_class("sky"), do: "border-sky-100"
  defp tone_class("indigo"), do: "border-indigo-100"
  defp tone_class("emerald"), do: "border-emerald-100"
  defp tone_class("amber"), do: "border-amber-100"
end
