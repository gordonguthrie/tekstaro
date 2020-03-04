defmodule TekstaroWeb.Helpers.Auth do

  def signed_in?(conn) do
    user_id = Plug.Conn.get_session(conn, :current_user_id)
    case user_id do
      nil -> false
      _   -> !!Tekstaro.Repo.get(Tekstaro.Accounts.User, user_id)
    end
  end

end
