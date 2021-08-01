defmodule PhoneDbWeb.Plug.AuthUser do
  @moduledoc "Authentication plugin"
  alias PhoneDb.Users

  def init(default), do: default

  @spec call(Plug.Conn.t(), keyword()) :: Plug.Conn.t()
  def call(conn, _opts) do
    with {username, password} <- Plug.BasicAuth.parse_basic_auth(conn),
         {:ok, %Users.User{} = user} <- Users.authenticate_user(username, password) do
      Plug.Conn.assign(conn, :current_user, user)
    else
      _ -> conn |> Plug.BasicAuth.request_basic_auth() |> Plug.Conn.halt()
    end
  end
end
