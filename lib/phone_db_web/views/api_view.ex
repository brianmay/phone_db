defmodule PhoneDbWeb.ApiView do
  use PhoneDbWeb, :view

  def render("incoming_call.json", %{action: action, name: name}) do
    %{
      action: action,
      name: name
    }
  end
end
