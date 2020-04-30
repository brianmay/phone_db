defmodule PhoneDb.Users.ErrorHandler do
  import Plug.Conn
  use PhoneDbWeb, :controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:danger, "You are not authorised to access that page")
    |> redirect(to: Routes.session_path(conn, :new, next: current_path(conn)))
  end
end
