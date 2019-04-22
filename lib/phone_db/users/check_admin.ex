defmodule PhoneDb.Users.CheckAdmin do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    if not user.is_admin do
      conn
      |> PhoneDb.Users.Auth.unauthorized_response()
      |> halt()
    else
      conn
    end
  end
end
