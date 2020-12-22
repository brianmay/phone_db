defmodule PhoneDbWeb.ApiController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Users.Auth

  def incoming_call(conn, %{
        "phone_number" => phone_number,
        "destination_number" => destination_number
      }) do
    if conn.assigns.current_user.is_phone do
      %{action: action, name: name} =
        PhoneDb.Contacts.incoming_phone_call(phone_number, destination_number)

      render(conn, "incoming_call.json", action: action, name: name)
    else
      Auth.unauthorized_response(conn)
    end
  end
end
