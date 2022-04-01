defmodule PhoneDbWeb.PageController do
  use PhoneDbWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", active: "index")
  end

  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    user = PhoneDbWeb.Auth.current_user(conn)

    if user != nil do
      sub = user["sub"]
      PhoneDbWeb.Endpoint.broadcast("users_socket:#{sub}", "disconnect", %{})
    end

    conn
    |> Plugoid.logout()
    |> put_session(:claims, nil)
    |> put_flash(:danger, "You are now logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  @spec login(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def login(conn, _params) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  @spec health(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def health(conn, _params) do
    send_resp(conn, 200, "healthy")
  end
end
