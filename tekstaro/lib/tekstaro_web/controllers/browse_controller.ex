defmodule TekstaroWeb.BrowseController do
  use TekstaroWeb, :controller

  def index(conn, %{"locale" => locale} = _params) do
    Gettext.put_locale(TekstaroWeb.Gettext, locale)
    render(conn, "index.html", locale: locale)
  end

end
