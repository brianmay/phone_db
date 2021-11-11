defmodule PhoneDbWeb.ApiControllerTest do
  use PhoneDbWeb.ConnCase

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    conn |> put_req_header("authorization", header_content)
  end

  describe "incoming call returns an action" do
    test "as anonymous fails", %{conn: conn} do
      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678"}
      conn = post(conn, url, data)
      assert response(conn, 401) == "Unauthorized"
    end

    test "as wrong auth fails", %{conn: conn} do
      conn = using_basic_auth(conn, "user", "some fake password")
      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678"}
      conn = post(conn, url, data)
      assert response(conn, 401) == "Unauthorized"
    end

    test "as phone user succeeds", %{conn: conn} do
      conn = using_basic_auth(conn, "user", "some password")

      url = Routes.api_path(conn, :incoming_call)
      data = %{"phone_number" => "0312345678", "destination_number" => "0412345678"}
      conn = post(conn, url, data)
      expected = %{"action" => "allow", "name" => nil}
      assert json_response(conn, 200) == expected
    end
  end
end
