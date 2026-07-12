defmodule BackendWeb.QrController do
  use BackendWeb, :controller

  alias Backend.Content

  def show(conn, %{"token" => token}) do
    case Content.get_workbook_page_by_token(token) do
      {:ok, page} -> render(conn, :show, page: page)
      {:error, :not_found} -> send_resp(conn, :not_found, "QR page not found")
    end
  end
end
