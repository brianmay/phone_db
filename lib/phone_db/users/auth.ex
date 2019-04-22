defmodule PhoneDb.Users.Auth do
  alias PhoneDb.Users

  @spec find_by_username_and_password(Plug.Conn.t(), String.t(), String.t()) :: Plug.Conn.t()
  def find_by_username_and_password(conn, username, password) do
    case Users.authenticate_user(username, password) do
      {:ok, user} -> Plug.Conn.assign(conn, :current_user, user)
      {:error, _} -> Plug.Conn.halt(conn)
    end
  end

  def unauthorized_response(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"message": "Unauthorized"}])
  end
end
