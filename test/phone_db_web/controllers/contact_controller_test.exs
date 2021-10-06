defmodule PhoneDbWeb.ContactControllerTest do
  use PhoneDbWeb.ConnCase

  alias PhoneDb.Contacts
  alias PhoneDb.Users
  alias PhoneDb.Users.Guardian

  @create_attrs %{
    action: "some action",
    name: "some name",
    comments: "some comments",
    phone_number: "some phone_number"
  }
  @update_attrs %{
    action: "some updated action",
    name: "some updated name",
    comments: "some updated comments",
    phone_number: "some updated phone_number"
  }
  @invalid_attrs %{action: nil, name: nil, phone_number: nil}

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

  def fixture(:contact) do
    {:ok, contact} = Contacts.create_contact(@create_attrs)
    contact
  end

  describe "new contact" do
    test "renders form", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = get(conn, Routes.contact_path(conn, :new))
      assert html_response(conn, 200) =~ "New Contact"
    end
  end

  describe "create contact" do
    test "redirects to show when data is valid", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = post(conn, Routes.contact_path(conn, :create), contact: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.show_contact_path(conn, :index, id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = post(conn, Routes.contact_path(conn, :create), contact: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Contact"
    end
  end

  describe "edit contact" do
    setup [:create_contact]

    test "renders form for editing chosen contact", %{conn: conn, contact: contact} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = get(conn, Routes.contact_path(conn, :edit, contact))
      assert html_response(conn, 200) =~ "Edit Contact"
    end
  end

  describe "update contact" do
    setup [:create_contact]

    test "redirects when data is valid", %{conn: conn, contact: contact} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = put(conn, Routes.contact_path(conn, :update, contact), contact: @update_attrs)
      assert redirected_to(conn) == Routes.show_contact_path(conn, :index, contact)
    end

    test "renders errors when data is invalid", %{conn: conn, contact: contact} do
      token = fixture(:trusted_token)
      conn = put_req_header(conn, "authorization", "bearer: " <> token)

      conn = put(conn, Routes.contact_path(conn, :update, contact), contact: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Contact"
    end
  end

  defp create_contact(_) do
    contact = fixture(:contact)
    {:ok, contact: contact}
  end
end
