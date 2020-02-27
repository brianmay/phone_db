defmodule PhoneDbWeb.PhoneCallController do
  use PhoneDbWeb, :controller

  alias Phoenix.LiveView

  def index(conn, params) do
    LiveView.Controller.live_render(conn, PhoneDbWeb.ListPhoneCallLive,
      session: %{"query" => Map.get(params, "query")}
    )
  end
end
