defmodule PhoneDbWeb.ApiControllerTest do
  use PhoneDbWeb.ConnCase

  alias PhoneDb.Users

  def fixture(:user) do
    {:ok, user} =
      Users.create_user(%{
        is_admin: false,
        is_phone: false,
        is_trusted: false,
        password: "some password",
        password_confirmation: "some password",
        username: "user"
      })

    user
  end

  def fixture(:phone_user) do
    {:ok, user} =
      Users.create_user(%{
        is_admin: false,
        is_phone: true,
        is_trusted: false,
        password: "some password",
        password_confirmation: "some password",
        username: "user"
      })

    user
  end

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end

  describe "incoming call returns an action" do
    test "as anonymous fails", %{conn: conn} do
      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678"}
      conn = post(conn, url, data)
      json_response(conn, 401)
    end

    test "as normal user fails", %{conn: conn} do
      fixture(:user)
      conn = using_basic_auth(conn, "user", "some password")

      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678", "destination_number" => "0412345678"}
      conn = post(conn, url, data)
      json_response(conn, 401)
    end

    test "as phone user succeeds", %{conn: conn} do
      fixture(:phone_user)
      conn = using_basic_auth(conn, "user", "some password")

      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678", "destination_number" => "0412345678"}
      conn = post(conn, url, data)
      expected = %{"action" => "allow", "name" => nil}
      assert json_response(conn, 200) == expected
    end
  end
end
