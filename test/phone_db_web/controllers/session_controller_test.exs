defmodule PhoneDbWeb.SessionControllerTest do
  use PhoneDbWeb.ConnCase

  alias PhoneDb.Users
  alias PhoneDb.Users.Guardian

  def fixture(:user) do
    {:ok, user} =
      Users.create_user(%{
        is_admin: false,
        is_phone: false,
        is_trusted: false,
        password: "some password",
        password_confirmation: "some password",
        username: "user"
      })

    user
  end

  def fixture(:token) do
    user = fixture(:user)
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)
    token
  end

  describe "anonymous access" do
    test "login as anonymous", %{conn: conn} do
      conn = get(conn, Routes.session_path(conn, :login))
      assert html_response(conn, 200) =~ "Login Page"
    end

    test "list contacts", %{conn: conn} do
      conn = get(conn, Routes.contact_path(conn, :index))
      response(conn, 401)
    end

    test "list phone calls", %{conn: conn} do
      conn = get(conn, Routes.phone_call_path(conn, :index))
      response(conn, 401)
    end
  end

  describe "login" do
    test "as user", %{conn: conn} do
      fixture(:user)

      conn =
        post(conn, Routes.session_path(conn, :new),
          user: %{"username" => "user", "password" => "some password"}
        )

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "logout" do
    test "as user", %{conn: conn} do
      token = fixture(:token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = post(conn, Routes.session_path(conn, :logout))
      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
