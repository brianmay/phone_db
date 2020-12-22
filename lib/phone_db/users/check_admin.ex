defmodule PhoneDb.Users.CheckAdmin do
  @moduledoc "Check user is admin"
  import Plug.Conn

  alias PhoneDb.Users.Auth

  def init(_params) do
  end

  def call(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    if user.is_admin do
      conn
    else
      conn
      |> Auth.unauthorized_response()
      |> halt()
    end
  end
end
