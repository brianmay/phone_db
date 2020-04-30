defmodule PhoneDbWeb.PageController do
  use PhoneDbWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", active: "index")
  end
end
