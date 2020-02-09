defmodule TekstaroWeb.PageController do
  use TekstaroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def redirect_frontpage(conn, _params) do
    conn
    |> redirect("/eo")
  end

end
