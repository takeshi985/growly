defmodule BackendWeb.Admin.ApiDocsController do
  use BackendWeb, :controller

  def index(conn, _params), do: render(conn, :index)
end
