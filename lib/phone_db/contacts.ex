defmodule PhoneDb.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias PhoneDb.Repo

  alias PhoneDb.Contacts.Contact
  alias PhoneDb.Contacts.PhoneCall

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts do
    Contact |> order_by(:name) |> Repo.all()
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(123)
      %Contact{}

      iex> get_contact!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(id), do: Repo.get!(Contact, id)

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(%{field: value})
      {:ok, %Contact{}}

      iex> create_contact(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(attrs \\ %{}) do
    %Contact{}
    |> Contact.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Contact{} = contact, attrs) do
    contact
    |> Contact.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(contact)
      %Ecto.Changeset{source: %Contact{}}

  """
  def change_contact(%Contact{} = contact) do
    Contact.changeset(contact, %{})
  end

  @doc """
  Returns the list of phone_calls.

  ## Examples

      iex> list_phone_calls()
      [%PhoneCall{}, ...]

  """
  def list_phone_calls do
    Repo.all(PhoneCall) |> Repo.preload(:contact)
  end

  @doc """
  Gets a single phone_call.

  Raises `Ecto.NoResultsError` if the PhoneCall does not exist.

  ## Examples

      iex> get_phone_call!(123)
      %PhoneCall{}

      iex> get_phone_call!(456)
      ** (Ecto.NoResultsError)

  """
  def get_phone_call!(id), do: Repo.get!(PhoneCall, id)

  @doc """
  Creates a phone_call.

  ## Examples

      iex> create_phone_call(%{field: value}, contact)
      {:ok, %PhoneCall{}}

      iex> create_phone_call(%{field: bad_value}, contact)
      {:error, %Ecto.Changeset{}}

  """
  def create_phone_call(attrs, contact) do
    contact
    |> Ecto.build_assoc(:phone_calls)
    |> PhoneCall.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Record a phone call and return required action.

  ## Examples

      iex> incoming_phone_call("12345768")
      "voicemail"

  """
  def incoming_phone_call(phone_number) do
    contact =
      case Repo.get_by(Contact, phone_number: phone_number) do
        nil ->
          {:ok, contact} = create_contact(%{phone_number: phone_number, action: "allow"})
          contact

        contact ->
          contact
      end

    {:ok, _} = create_phone_call(%{action: contact.action}, contact)

    %{
      action: contact.action,
      name: contact.name
    }
  end
end
