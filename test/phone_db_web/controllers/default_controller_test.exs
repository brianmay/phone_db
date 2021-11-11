defmodule PhoneDbWeb.DefaultControllerTest do
  use PhoneDbWeb.ConnCase

  alias PhoneDb.Contacts

  @create_attrs %{action: "some action", name: "some name", order: 42, regexp: "some regexp"}
  @update_attrs %{
    action: "some updated action",
    name: "some updated name",
    order: 43,
    regexp: "some updated regexp"
  }
  @invalid_attrs %{action: nil, name: nil, order: nil, regexp: nil}

  def fixture(:default) do
    {:ok, default} = Contacts.create_default(@create_attrs)
    default
  end

  def fake_auth(conn) do
    # Note if we don't recycle connection, it could get recycled anyway,
    # and we lose the value we set here.
    conn
    |> ensure_recycled()
    |> put_private(:plugoid_authenticated, true)
  end

  describe "index" do
    test "lists all defaults", %{conn: conn} do
      conn = fake_auth(conn)
      conn = get(conn, Routes.default_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Defaults"
    end
  end

  describe "new default" do
    test "renders form", %{conn: conn} do
      conn = fake_auth(conn)
      conn = get(conn, Routes.default_path(conn, :new))
      assert html_response(conn, 200) =~ "New Default"
    end
  end

  describe "create default" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = fake_auth(conn)
      conn = post(conn, Routes.default_path(conn, :create), default: @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.default_path(conn, :show, id)

      conn = fake_auth(conn)
      conn = get(conn, Routes.default_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Default"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = fake_auth(conn)
      conn = post(conn, Routes.default_path(conn, :create), default: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Default"
    end
  end

  describe "edit default" do
    setup [:create_default]

    test "renders form for editing chosen default", %{conn: conn, default: default} do
      conn = fake_auth(conn)
      conn = get(conn, Routes.default_path(conn, :edit, default))
      assert html_response(conn, 200) =~ "Edit Default"
    end
  end

  describe "update default" do
    setup [:create_default]

    test "redirects when data is valid", %{conn: conn, default: default} do
      conn = fake_auth(conn)
      conn = put(conn, Routes.default_path(conn, :update, default), default: @update_attrs)
      assert redirected_to(conn) == Routes.default_path(conn, :show, default)

      conn = fake_auth(conn)
      conn = get(conn, Routes.default_path(conn, :show, default))
      assert html_response(conn, 200) =~ "some updated action"
    end

    test "renders errors when data is invalid", %{conn: conn, default: default} do
      conn = fake_auth(conn)
      conn = put(conn, Routes.default_path(conn, :update, default), default: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Default"
    end
  end

  describe "delete default" do
    setup [:create_default]

    test "deletes chosen default", %{conn: conn, default: default} do
      conn = fake_auth(conn)
      conn = delete(conn, Routes.default_path(conn, :delete, default))
      assert redirected_to(conn) == Routes.default_path(conn, :index)

      assert_error_sent 404, fn ->
        conn = fake_auth(conn)
        get(conn, Routes.default_path(conn, :show, default))
      end
    end
  end

  defp create_default(_) do
    default = fixture(:default)
    {:ok, default: default}
  end
end
