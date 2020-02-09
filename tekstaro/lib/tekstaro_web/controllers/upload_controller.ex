defmodule TekstaroWeb.UploadController do
  use TekstaroWeb, :controller

  def index(conn, _params) do
    render(conn, "upload.html")
  end

  def upload(conn, %{"text" => text, "title" => title, "url" => url} = params) do
    IO.inspect(params, label: "params in upload")
    response = Procezo.procezu(text, title, url, "Gordon Guthrie")
    IO.inspect(response)
    render(conn, "upload.json")
  end

end
