defmodule TekstaroWeb.BrowseController do
  use TekstaroWeb, :controller

  def index(conn, %{"locale" => locale} = _params) do
    render(conn, "index.html", locale: locale)
  end

end
