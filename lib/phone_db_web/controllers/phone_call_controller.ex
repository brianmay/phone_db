defmodule PhoneDbWeb.PhoneCallController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Contacts

  def index(conn, _params) do
    phone_calls = Contacts.list_phone_calls()
    render(conn, "index.html", phone_calls: phone_calls)
  end
end
