defmodule PhoneDbWeb.HealthCheckController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Release

  def index(conn, _params) do
    case Release.health_check() do
      :ok ->
        text(conn, "HEALTHY")

      {:error, _reason} ->
        conn |> put_status(500) |> text("ERROR")
    end
  end
end
