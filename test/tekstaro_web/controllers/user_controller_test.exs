defmodule TekstaroWeb.UserControllerTest do
  use TekstaroWeb.ConnCase

  alias Tekstaro.Accounts

  @create_attrs %{encrypted_password: "some encrypted_password", username: "some username"}
  # @update_attrs  %{encrypted_password: "some updated encrypted_password", username: "some updated username"}
  @invalid_attrs %{encrypted_password: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  #  describe "index" do
  #    test "lists all users", %{conn: conn} do
  #      conn = get(conn, Routes.user_path(conn, :index, "en"))
  #      assert html_response(conn, 200) =~ "Listing Users"
  #    end
  #  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new, "en"))
      assert html_response(conn, 200) =~ "Sign out"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create, "en"), user: @create_attrs)
      # login here redirects to the home page
      assert %{} = redirected_params(conn)
      assert redirected_to(conn) == "/"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create, "en"), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Register"
    end
  end

  #  describe "edit user" do
  #    setup [:create_user]
  #
  #    test "renders form for editing chosen user", %{conn: conn, user: user} do
  #      conn = get(conn, Routes.user_path(conn, :edit, user))
  #      assert html_response(conn, 200) =~ "Edit User"
  #    end
  #  end

  #  describe "update user" do
  #    setup [:create_user]

  #    test "redirects when data is valid", %{conn: conn, user: user} do
  #      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

  #      conn = get(conn, Routes.user_path(conn, "en", :show, user))
  #      assert html_response(conn, 200) =~ "some updated encrypted_password"
  #    end

  #    test "renders errors when data is invalid", %{conn: conn, user: user} do
  #      conn = put(conn, Routes.user_path(conn, "en", :update, user), user: @invalid_attrs)
  #      assert html_response(conn, 200) =~ "Edit User"
  #    end
  #  end

  #  describe "delete user" do
  #    setup [:create_user]

  #    test "deletes chosen user", %{conn: conn, user: user} do
  #      conn = delete(conn, Routes.user_path(conn, :delete, user))
  #      assert redirected_to(conn) == Routes.user_path(conn, "en", :index)
  #      assert_error_sent 404, fn ->
  #        get(conn, Routes.user_path(conn, "en", :show, user))
  #      end
  #    end
  #  end

  # helper fn not used
  #  defp create_user(_) do
  #    user = fixture(:user)
  #    {:ok, user: user}
  #  end
end
