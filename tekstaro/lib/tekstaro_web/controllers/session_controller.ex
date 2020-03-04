defmodule TekstaroWeb.SessionController do

  use TekstaroWeb, :controller

  alias Tekstaro.Accounts

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def login(conn, %{"session" => auth_params}) do
    user = Accounts.get_by_username(auth_params["username"])
    case Comeonin.Bcrypt.check_pass(user, auth_params["password"]) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, gettext("Signed in successfully"))
        |> redirect(to: "/")
      {:error, _e} ->
        conn
        |> put_flash(:error, gettext("there was a problem with your username/password"))
        |>render("new.html")
      end
    end

    def logout(conn, _params) do
      conn
      |> delete_session(:current_user_id)
      |> put_flash("info", gettext("Signed out sucessfully"))
      |> redirect(to: "/")
    end
end
