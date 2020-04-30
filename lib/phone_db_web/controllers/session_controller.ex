defmodule PhoneDbWeb.SessionController do
  use PhoneDbWeb, :controller

  alias PhoneDb.{Users, Users.User, Users.Guardian}
  alias PhoneDbWeb.Router.Helpers, as: Routes

  def new(conn, _) do
    changeset = Users.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)

    if maybe_user do
      redirect(conn, to: Routes.page_path(conn, :index))
    else
      render(conn, "new.html",
        changeset: changeset,
        action: Routes.session_path(conn, :login),
        active: "index"
      )
    end
  end

  def login(conn, %{"user" => %{"username" => username, "password" => password}}) do
    Users.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp login_reply({:ok, user}, conn) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> Guardian.Plug.sign_in(user)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp login_reply({:error, _reason}, conn) do
    conn
    |> put_flash(:danger, "Invalid credentials")
    |> new(%{})
  end
end
