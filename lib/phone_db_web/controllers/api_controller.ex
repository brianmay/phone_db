defmodule PhoneDbWeb.ApiController do
  use PhoneDbWeb, :controller

  def incoming_call(conn, %{
        "phone_number" => phone_number,
        "destination_number" => destination_number
      }) do
    if conn.assigns.current_user.is_phone do
      %{action: action, name: name} =
        PhoneDb.Contacts.incoming_phone_call(phone_number, destination_number)

      render(conn, "incoming_call.json", action: action, name: name)
    else
      # Don't redirect failures to login page here for API calls.
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(401, ~s[{"message": "Unauthorized"}])
      |> halt()
    end
  end
end
