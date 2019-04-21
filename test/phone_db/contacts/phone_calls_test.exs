defmodule PhoneDb.PhoneCallsTest do
  use PhoneDb.DataCase

  alias PhoneDb.Contacts
  alias PhoneDb.Repo

  describe "phone_calls" do
    alias PhoneDb.Contacts.PhoneCall

    @valid_attrs %{action: "some action"}
    @invalid_attrs %{action: nil}

    def contact_fixture(attrs \\ %{}) do
      valid_attrs = %{
        action: "some action",
        name: "some name",
        phone_number: "some phone_number"
      }

      {:ok, contact} =
        attrs
        |> Enum.into(valid_attrs)
        |> PhoneDb.Contacts.create_contact()

      contact
    end

    def phone_call_fixture(attrs \\ %{}) do
      contact = contact_fixture()

      {:ok, phone_call} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contacts.create_phone_call(contact)

      phone_call
    end

    test "list_phone_calls/0 returns all phone_calls" do
      phone_call = phone_call_fixture() |> Repo.preload(:contact)
      assert Contacts.list_phone_calls() == [phone_call]
    end

    test "get_phone_call!/1 returns the phone_call with given id" do
      phone_call = phone_call_fixture()
      assert Contacts.get_phone_call!(phone_call.id) == phone_call
    end

    test "create_phone_call/1 with valid data creates a phone_call" do
      contact = contact_fixture()

      assert {:ok, %PhoneCall{} = phone_call} = Contacts.create_phone_call(@valid_attrs, contact)

      assert phone_call.action == "some action"
    end

    test "create_phone_call/1 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.create_phone_call(@invalid_attrs, contact)
    end

    test "delete_phone_call/1 deletes the phone_call" do
      phone_call = phone_call_fixture()
      assert {:ok, %PhoneCall{}} = Contacts.delete_phone_call(phone_call)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_phone_call!(phone_call.id) end
    end

    test "incoming_phone_call/1 creates a contact and a phone_call" do
      response = Contacts.incoming_phone_call("0312345678")
      assert response == %{
        action: "allow",
        name: nil,
      }

      contacts = Contacts.list_contacts()
      assert length(contacts) == 1
      contact = hd(contacts)

      assert contact.phone_number == "0312345678"
      assert contact.action == "allow"
      assert contact.name == nil

      phone_calls = Contacts.list_phone_calls()
      assert length(phone_calls) == 1
      phone_call = hd(phone_calls)

      assert phone_call.contact_id == contact.id
      assert phone_call.action == "allow"
    end

    test "incoming_phone_call/1 for existing contact creates phone_call" do
      {:ok, contact} =
        PhoneDb.Contacts.create_contact(%{
          action: "voicemail",
          name: "Idiot",
          phone_number: "0312345678"
        })

      response = Contacts.incoming_phone_call("0312345678")
      assert response == %{
        action: "voicemail",
        name: "Idiot",
      }

      contacts = Contacts.list_contacts()
      assert length(contacts) == 1
      listed_contact = hd(contacts)
      assert listed_contact.id == contact.id

      phone_calls = Contacts.list_phone_calls()
      assert length(phone_calls) == 1
      phone_call = hd(phone_calls)

      assert phone_call.contact_id == contact.id
      assert phone_call.action == "voicemail"
    end
  end
end
