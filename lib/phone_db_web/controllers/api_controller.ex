defmodule PhoneDbWeb.ApiController do
  use PhoneDbWeb, :controller

  def incoming_call(conn, %{
        "phone_number" => phone_number,
        "destination_number" => destination_number
      }) do
    %{action: action, name: name} =
      PhoneDb.Contacts.incoming_phone_call(phone_number, destination_number)

    render(conn, "incoming_call.json", action: action, name: name)
  end
end
