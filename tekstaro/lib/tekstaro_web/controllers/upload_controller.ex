defmodule TekstaroWeb.UploadController do
  use TekstaroWeb, :controller

  plug :check_auth when action in [:index, :upload]

  def index(conn, _params) do
    render(conn, "upload.html")
  end

  def upload(conn, %{"text" => text, "title" => title, "url" => url}) do
    user_id = get_session(conn, :current_user_id)
    current_user = Tekstaro.Accounts.get_user!(user_id)
    site = get_site(url)

    case is_input_valid(title, site) do
      true ->
        {:ok, s} = site
        channel = Tekstaro.Text.Text.start_child(text, title, url, s, current_user)
        render(conn, "upload.json", channel: channel)

      false ->
        conn
        |> put_status(403)
        |> render("fail.json", msg: "please provide a title and a valid url")
    end
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

  defp is_input_valid("", _),          do: false
  defp is_input_valid(_, {:error, _}), do: false
  defp is_input_valid(_, _),           do: true

  defp get_site(url) do
    uri = URI.parse(url)

    case uri do
      %URI{scheme: nil,    host: nil}  -> {:error, "not a url"}
      %URI{scheme: nil,    host: host} -> {:ok,    "http://" <> host}
      %URI{scheme: scheme, host: host} -> {:ok,     scheme <> "://" <> host}
    end
  end
end
