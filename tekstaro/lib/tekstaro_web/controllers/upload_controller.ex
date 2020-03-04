defmodule TekstaroWeb.UploadController do
  use TekstaroWeb, :controller

  plug :check_auth when action in [:index, :upload]

  def index(conn, _params) do
    render(conn, "upload.html")
  end

  def upload(conn, %{"text" => text, "title" => title, "url" => url}) do
    channel = Tekstaro.Text.Text.start_child(text, title, url)
    render(conn, "upload.json", channel: channel)
  end

  defp check_auth(conn, _params) do
      if user_id = get_session(conn, :current_user_id) do
        current_user = Tekstaro.Accounts.get_user!(user_id)
        conn
        |> assign(:current_user, current_user)
      else
        conn
        |> put_flash(:error, "You need to be signed in to access that page.")
        |> redirect(to: "/")
        |> halt()
      end
    end

end
