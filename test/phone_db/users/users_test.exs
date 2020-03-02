defmodule PhoneDb.UsersTest do
  use PhoneDb.DataCase

  alias PhoneDb.Users

  describe "users" do
    alias PhoneDb.Users.User

    @create_attrs %{
      is_admin: true,
      is_phone: true,
      is_trusted: true,
      password: "some password",
      password_confirmation: "some password",
      username: "some username"
    }
    @update_attrs %{
      is_admin: false,
      is_phone: false,
      is_trusted: false,
      username: "some updated username"
    }
    @invalid_attrs %{is_admin: nil, is_phone: nil, is_trusted: nil, username: nil}
    @password_attrs %{
      password: "some other password",
      password_confirmation: "some other password"
    }
    @invalid_password_attrs %{
      password: "some password",
      password_confirmation: "some other password"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@create_attrs)
        |> Users.create_user()

      %{user | password: nil}
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@create_attrs)
      assert user.is_admin == true
      assert user.is_phone == true
      assert user.is_trusted == true
      {:ok, _} = Bcrypt.check_pass(user, "some password")
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.is_admin == false
      assert user.is_phone == false
      assert user.is_trusted == false
      {:ok, _} = Bcrypt.check_pass(user, "some password")
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "update_password/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Users.update_password(user, @password_attrs)
      {:ok, _} = Bcrypt.check_pass(user, "some other password")
    end

    test "update_password/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_password(user, @invalid_password_attrs)
      assert user == Users.get_user!(user.id)
      {:ok, _} = Bcrypt.check_pass(user, "some password")
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end

    test "change_password/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_password(user)
    end

    test "authenticate_user/2 returns success" do
      user = user_fixture()
      {:ok, got_user} = Users.authenticate_user("some username", "some password")
      assert user == got_user
    end

    test "authenticate_user/2 with invalid username" do
      user_fixture()

      {:error, :invalid_credentials} = Users.authenticate_user("other username", "some password")
    end

    test "authenticate_user/2 with invalid password" do
      user_fixture()
      {:error, :invalid_credentials} = Users.authenticate_user("some username", "other password")
    end
  end
end
