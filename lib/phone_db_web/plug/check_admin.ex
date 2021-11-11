defmodule PhoneDbWeb.Plug.CheckAdmin do
  @moduledoc "Plugin to check if user is admin"
  import Plug.Conn

  use PhoneDbWeb, :controller

  def init(_params) do
  end

  def call(conn, _params) do
    user = PhoneDbWeb.Auth.current_user(conn)

    if PhoneDbWeb.Auth.user_is_admin?(user) do
      conn
    else
      conn
      |> put_flash(:danger, "You must be admin to access this.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
