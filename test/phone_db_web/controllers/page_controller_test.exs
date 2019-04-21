defmodule PhoneDbWeb.PageControllerTest do
  use PhoneDbWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phone DB!"
  end
end
