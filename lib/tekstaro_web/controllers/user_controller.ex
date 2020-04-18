defmodule TekstaroWeb.UserController do
  use TekstaroWeb, :controller

  alias Tekstaro.Accounts
  alias Tekstaro.Accounts.User

  def new(conn, %{"locale" => locale} = _params) do
    Gettext.put_locale(TekstaroWeb.Gettext, locale)
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params, "locale" => locale} = _params) do
    Gettext.put_locale(TekstaroWeb.Gettext, locale)
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, gettext("Signed up successfully."))
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
