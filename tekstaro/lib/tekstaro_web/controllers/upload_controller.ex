defmodule TekstaroWeb.UploadController do
  use TekstaroWeb, :controller

  def index(conn, _params) do
    render(conn, "upload.html")
  end

  def upload(conn, %{"text" => text, "title" => title, "url" => url}) do
    channel = Tekstaro.Text.Text.start_child(text, title, url)
    render(conn, "upload.json", channel: channel)
  end

end