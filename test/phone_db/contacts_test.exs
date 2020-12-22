defmodule PhoneDb.ContactsTest do
  use PhoneDb.DataCase

  alias PhoneDb.Contacts

  defp get_actions, do: Application.get_env(:phone_db, :actions)

  describe "actions" do
    test "show_action/0 returns correct values" do
      Enum.each(get_actions(), fn {word, key} ->
        assert word == Contacts.show_action(key)
      end)

      assert "Unknown (abc)" == Contacts.show_action("abc")
    end
  end

  describe "defaults" do
    alias PhoneDb.Contacts.Default

    @valid_attrs %{action: "some action", name: "some name", order: 42, regexp: "some regexp"}
    @update_attrs %{
      action: "some updated action",
      name: "some updated name",
      order: 43,
      regexp: "some updated regexp"
    }
    @invalid_attrs %{action: nil, name: nil, order: nil, regexp: nil}

    def default_fixture(attrs \\ %{}) do
      {:ok, default} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contacts.create_default()

      default
    end

    test "list_defaults/0 returns all defaults" do
      default = default_fixture()
      assert Contacts.list_defaults() == [default]
    end

    test "get_default!/1 returns the default with given id" do
      default = default_fixture()
      assert Contacts.get_default!(default.id) == default
    end

    test "create_default/1 with valid data creates a default" do
      assert {:ok, %Default{} = default} = Contacts.create_default(@valid_attrs)
      assert default.action == "some action"
      assert default.name == "some name"
      assert default.order == 42
      assert default.regexp == "some regexp"
    end

    test "create_default/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_default(@invalid_attrs)
    end

    test "update_default/2 with valid data updates the default" do
      default = default_fixture()
      assert {:ok, %Default{} = default} = Contacts.update_default(default, @update_attrs)
      assert default.action == "some updated action"
      assert default.name == "some updated name"
      assert default.order == 43
      assert default.regexp == "some updated regexp"
    end

    test "update_default/2 with invalid data returns error changeset" do
      default = default_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_default(default, @invalid_attrs)
      assert default == Contacts.get_default!(default.id)
    end

    test "delete_default/1 deletes the default" do
      default = default_fixture()
      assert {:ok, %Default{}} = Contacts.delete_default(default)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_default!(default.id) end
    end

    test "change_default/1 returns a default changeset" do
      default = default_fixture()
      assert %Ecto.Changeset{} = Contacts.change_default(default)
    end

    test "search_defaults/1 returns 1st default" do
      expected = default_fixture(%{regexp: "^42", order: 42})
      default_fixture(%{regexp: "^42", order: 43})
      assert expected == Contacts.search_defaults("4211")
    end

    test "search_defaults/1 returns 2nd default" do
      default_fixture(%{regexp: "^41", order: 42})
      expected = default_fixture(%{regexp: "^42", order: 43})
      assert expected == Contacts.search_defaults("4211")
    end

    test "search_defaults/1 returns a none" do
      default_fixture(%{regexp: "^42", order: 42})
      assert nil == Contacts.search_defaults("4111")
    end
  end
end
