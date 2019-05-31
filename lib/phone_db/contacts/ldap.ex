defmodule PhoneDb.Contacts.Ldap do
  alias PhoneDb.Contacts.Contact
  @behaviour PhoneDb.Contacts.SyncBehaviour

  require Paddle.Class.Helper

  Paddle.Class.Helper.gen_class_from_schema(
    PhoneDb.Contacts.Ldap.Person,
    ["person"],
    "ou=people",
    :telephoneNumber
  )

  alias PhoneDb.Contacts.Ldap.Person

  defp authenticate() do
    config = Application.get_env(:paddle, Paddle)
    username = Keyword.fetch!(config, :username)
    password = Keyword.fetch!(config, :password)
    :ok = Paddle.authenticate([cn: username], password)
  end

  defp contact_to_person(%Contact{} = contact) do
    %Person{
      telephoneNumber: contact.phone_number,
      cn: contact.name,
      sn: contact.name
    }
  end

  defp include_contact_in_ldap?(%Contact{} = contact) do
    cond do
      contact.name == nil -> false
      contact.phone_number == "anonymous" -> false
      contact.action != "allow" -> false
      true -> true
    end
  end

  defp do_create_contact(%Contact{} = contact) do
    person = contact_to_person(contact)

    case include_contact_in_ldap?(contact) do
      true -> Paddle.add(person)
      false -> :ok
    end
  end

  defp do_update_contact(%Person{} = person, %Contact{} = contact) do
    case include_contact_in_ldap?(contact) do
      true -> Paddle.modify(person, replace: {"cn", contact.name}, replace: {"sn", contact.name})
      false -> Paddle.delete(person)
    end
  end

  def update_contact(%Contact{} = contact) do
    authenticate()

    case Paddle.get(%PhoneDb.Contacts.Ldap.Person{telephoneNumber: contact.phone_number}) do
      {:error, :noSuchObject} -> do_create_contact(contact)
      {:ok, [person]} -> do_update_contact(person, contact)
    end
  end
end
