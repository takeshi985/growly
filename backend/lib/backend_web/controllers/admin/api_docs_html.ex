defmodule BackendWeb.Admin.ApiDocsHTML do
  use BackendWeb, :html

  embed_templates "api_docs_html/*"

  attr :method, :string, required: true
  attr :path, :string, required: true
  attr :purpose, :string, required: true

  def endpoint(assigns) do
    ~H"""
    <article class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
      <div class="flex flex-wrap items-center gap-3">
        <span class="rounded-lg bg-slate-900 px-3 py-1 text-xs font-black text-white">{@method}</span>
        <code class="font-bold text-violet-700">{@path}</code>
      </div>
      <p class="mt-3 leading-7 text-slate-600">{@purpose}</p>
    </article>
    """
  end
end
