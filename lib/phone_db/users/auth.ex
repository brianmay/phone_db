defmodule PhoneDb.Users.Auth do
  @moduledoc "Authentication functions"

  def unauthorized_response(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(401, ~s[{"message": "Unauthorized"}])
  end
end
