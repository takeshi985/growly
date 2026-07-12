defmodule BackendWeb.Admin.ContentController do
  use BackendWeb, :controller

  alias Backend.Content

  def index(conn, _params) do
    render(conn, :index, summary: Content.content_summary())
  end
end
