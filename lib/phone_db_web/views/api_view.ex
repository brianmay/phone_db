defmodule PhoneDbWeb.ApiView do
  use PhoneDbWeb, :html

  def render("incoming_call.json", %{action: action, name: name}) do
    %{
      action: action,
      name: name
    }
  end
end
