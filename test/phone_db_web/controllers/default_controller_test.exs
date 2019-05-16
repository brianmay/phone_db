defmodule PhoneDbWeb.DefaultControllerTest do
  use PhoneDbWeb.ConnCase

  alias PhoneDb.Contacts
  alias PhoneDb.Users
  alias PhoneDb.Users.Guardian

  @create_attrs %{action: "some action", name: "some name", order: 42, regexp: "some regexp"}
  @update_attrs %{
    action: "some updated action",
    name: "some updated name",
    order: 43,
    regexp: "some updated regexp"
  }
  @invalid_attrs %{action: nil, name: nil, order: nil, regexp: nil}

  def fixture(:trusted_token) do
    {:ok, user} =
      Users.create_user(%{
        is_admin: false,
        is_phone: false,
        is_trusted: true,
        password: "some password",
        password_confirmation: "some password",
        username: "trusted"
      })

    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)
    token
  end

  def fixture(:default) do
    {:ok, default} = Contacts.create_default(@create_attrs)
    default
  end

  describe "index" do
    test "lists all defaults", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = get(conn, Routes.default_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Defaults"
    end
  end

  describe "new default" do
    test "renders form", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = get(conn, Routes.default_path(conn, :new))
      assert html_response(conn, 200) =~ "New Default"
    end
  end

  describe "create default" do
    test "redirects to show when data is valid", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = post(conn, Routes.default_path(conn, :create), default: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.default_path(conn, :show, id)

      conn = get(conn, Routes.default_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Default"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = post(conn, Routes.default_path(conn, :create), default: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Default"
    end
  end

  describe "edit default" do
    setup [:create_default]

    test "renders form for editing chosen default", %{conn: conn, default: default} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = get(conn, Routes.default_path(conn, :edit, default))
      assert html_response(conn, 200) =~ "Edit Default"
    end
  end

  describe "update default" do
    setup [:create_default]

    test "redirects when data is valid", %{conn: conn, default: default} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = put(conn, Routes.default_path(conn, :update, default), default: @update_attrs)
      assert redirected_to(conn) == Routes.default_path(conn, :show, default)

      conn = get(conn, Routes.default_path(conn, :show, default))
      assert html_response(conn, 200) =~ "some updated action"
    end

    test "renders errors when data is invalid", %{conn: conn, default: default} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = put(conn, Routes.default_path(conn, :update, default), default: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Default"
    end
  end

  describe "delete default" do
    setup [:create_default]

    test "deletes chosen default", %{conn: conn, default: default} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = delete(conn, Routes.default_path(conn, :delete, default))
      assert redirected_to(conn) == Routes.default_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.default_path(conn, :show, default))
      end
    end
  end

  defp create_default(_) do
    default = fixture(:default)
    {:ok, default: default}
  end
end
