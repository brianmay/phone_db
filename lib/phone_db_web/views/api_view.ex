defmodule PhoneDbWeb.ApiView do
  use PhoneDbWeb, :view

  def render("incoming_call.json", %{action: action}) do
    %{
      action: action
    }
  end
end
