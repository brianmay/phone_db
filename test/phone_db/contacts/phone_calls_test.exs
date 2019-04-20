defmodule PhoneDb.PhoneCallsTest do
  use PhoneDb.DataCase

  alias PhoneDb.PhoneCalls

  describe "phone_calls" do
    alias PhoneDb.Contacts.PhoneCall

    @valid_attrs %{action: "some action"}
    @update_attrs %{
      action: "some updated action"
    }
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
        |> PhoneCalls.create_phone_call(contact)

      phone_call
    end

    test "list_phone_calls/0 returns all phone_calls" do
      phone_call = phone_call_fixture()
      assert PhoneCalls.list_phone_calls() == [phone_call]
    end

    test "get_phone_call!/1 returns the phone_call with given id" do
      phone_call = phone_call_fixture()
      assert PhoneCalls.get_phone_call!(phone_call.id) == phone_call
    end

    test "create_phone_call/1 with valid data creates a phone_call" do
      contact = contact_fixture()

      assert {:ok, %PhoneCall{} = phone_call} =
               PhoneCalls.create_phone_call(@valid_attrs, contact)

      assert phone_call.action == "some action"
    end

    test "create_phone_call/1 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = PhoneCalls.create_phone_call(@invalid_attrs, contact)
    end

    test "update_phone_call/2 with valid data updates the phone_call" do
      phone_call = phone_call_fixture()

      assert {:ok, %PhoneCall{} = phone_call} =
               PhoneCalls.update_phone_call(phone_call, @update_attrs)

      assert phone_call.action == "some updated action"
    end

    test "update_phone_call/2 with invalid data returns error changeset" do
      phone_call = phone_call_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PhoneCalls.update_phone_call(phone_call, @invalid_attrs)

      assert phone_call == PhoneCalls.get_phone_call!(phone_call.id)
    end

    test "delete_phone_call/1 deletes the phone_call" do
      phone_call = phone_call_fixture()
      assert {:ok, %PhoneCall{}} = PhoneCalls.delete_phone_call(phone_call)
      assert_raise Ecto.NoResultsError, fn -> PhoneCalls.get_phone_call!(phone_call.id) end
    end

    test "change_phone_call/1 returns a phone_call changeset" do
      phone_call = phone_call_fixture()
      assert %Ecto.Changeset{} = PhoneCalls.change_phone_call(phone_call)
    end
  end
end
