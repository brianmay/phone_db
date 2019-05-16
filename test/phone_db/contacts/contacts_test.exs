defmodule PhoneDb.Contacts.ContactsTest do
  use PhoneDb.DataCase

  alias PhoneDb.Contacts

  describe "contacts" do
    alias PhoneDb.Contacts.Contact

    @valid_attrs %{action: "some action", name: "some name", phone_number: "some phone_number"}
    @update_attrs %{
      action: "some updated action",
      name: "some updated name",
      phone_number: "some updated phone_number"
    }
    @invalid_attrs %{action: nil, name: nil, phone_number: nil}

    def contact_fixture(attrs \\ %{}) do
      {:ok, contact} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contacts.create_contact()

      contact
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end

    test "count_contacts/0 counts all contacts" do
      contact_fixture()
      assert Contacts.count_contacts() == 1
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      assert {:ok, %Contact{} = contact} = Contacts.create_contact(@valid_attrs)
      assert contact.action == "some action"
      assert contact.name == "some name"
      assert contact.phone_number == "some phone_number"
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, @update_attrs)
      assert contact.action == "some updated action"
      assert contact.name == "some updated name"
      assert contact.phone_number == "some phone_number"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
