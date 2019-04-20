defmodule PhoneDbWeb.ApiController do
  use PhoneDbWeb, :controller

  def incoming_call(conn, %{"phone_number" => phone_number}) do
    action = PhoneDb.PhoneCalls.incoming_phone_call(phone_number)
    render(conn, "incoming_call.json", action: action)
  end
end
