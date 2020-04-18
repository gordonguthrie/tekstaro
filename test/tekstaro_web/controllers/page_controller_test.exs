defmodule TekstaroWeb.PageControllerTest do
  use TekstaroWeb.ConnCase

  test "GET /en", %{conn: conn} do
    conn = get(conn, "/en")
    assert html_response(conn, 200) =~ "a corpus of Esperanto usage"
  end
end
