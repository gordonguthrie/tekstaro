defmodule TekstaroWeb.UploadController do
  use TekstaroWeb, :controller

  def index(conn, _params) do
    render(conn, "upload.html")
  end

  def upload(conn, %{"text" => text, "title" => title, "url" => url} = params) do
    ret = Tekstaro.Text.Text.start_child(text, title, url)
    IO.inspect(ret, label: "in upload controller got")
    render(conn, "upload.json")
  end

end