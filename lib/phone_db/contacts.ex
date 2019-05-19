defmodule PhoneDb.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias PhoneDb.Repo

  alias PhoneDb.Contacts.Contact
  alias PhoneDb.Contacts.PhoneCall

  @actions Application.get_env(:phone_db, :actions)

  defp contacts_query(order_by, query) do
    q = Contact |> order_by(^order_by)

    case query do
      nil ->
        q

      "" ->
        q

      _ ->
        query = "%#{String.replace(query, "%", "\\%")}%"
        where(q, [c], ilike(c.phone_number, ^query) or ilike(c.name, ^query))
    end
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts()
      [%Contact{}, ...]

  """
  def list_contacts(order_by \\ [{:asc, :name}], query \\ nil, page_number \\ 1, page_size \\ 100) do
    offset = page_size * (page_number - 1)

    contacts_query(order_by, query)
    |> limit([_], ^page_size)
    |> offset([_], ^offset)
    |> Repo.all()
  end

  @doc """
  Returns the count of contacts.

  ## Examples

      iex> count_contacts()
      10

  """
  def count_contacts(query \\ nil) do
    contacts_query([], query) |> select([c], count(c.id)) |> Repo.one()
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
    %PhoneCall{}
    |> PhoneCall.changeset(attrs)
    |> Ecto.Changeset.change(contact_id: contact.id)
    |> Repo.insert()
  end

  @doc """
  Record a phone call and return required action.

  ## Examples

      iex> incoming_phone_call("12345768")
      "voicemail"

  """
  def incoming_phone_call(phone_number) do
    contact = get_contact_for_phone_number(phone_number)
    {:ok, _} = create_phone_call(%{action: contact.action}, contact)

    %{
      action: contact.action,
      name: contact.name
    }
  end

  alias PhoneDb.Contacts.Default

  @doc """
  Returns the list of defaults.

  ## Examples

      iex> list_defaults()
      [%Default{}, ...]

  """
  def list_defaults do
    Repo.all(Default, order_by: :order)
  end

  @doc """
  Gets a single default.

  Raises `Ecto.NoResultsError` if the Default does not exist.

  ## Examples

      iex> get_default!(123)
      %Default{}

      iex> get_default!(456)
      ** (Ecto.NoResultsError)

  """
  def get_default!(id), do: Repo.get!(Default, id)

  @doc """
  Creates a default.

  ## Examples

      iex> create_default(%{field: value})
      {:ok, %Default{}}

      iex> create_default(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_default(attrs \\ %{}) do
    %Default{}
    |> Default.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a default.

  ## Examples

      iex> update_default(default, %{field: new_value})
      {:ok, %Default{}}

      iex> update_default(default, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_default(%Default{} = default, attrs) do
    default
    |> Default.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Default.

  ## Examples

      iex> delete_default(default)
      {:ok, %Default{}}

      iex> delete_default(default)
      {:error, %Ecto.Changeset{}}

  """
  def delete_default(%Default{} = default) do
    Repo.delete(default)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking default changes.

  ## Examples

      iex> change_default(default)
      %Ecto.Changeset{source: %Default{}}

  """
  def change_default(%Default{} = default) do
    Default.changeset(default, %{})
  end

  @doc """
  Search defaults for a phone number

  ## Examples

      iex> search_defaults("12345768")
      %Default{}

  """
  def search_defaults(phone_number) do
    defaults = list_defaults()

    Enum.find(defaults, fn d ->
      case Regex.compile(d.regexp) do
        {:error, reason} ->
          IO.puts("Invalid regexp #{d.regexp} ignored: #{reason}")
          false

        {:ok, regex} ->
          Regex.run(regex, phone_number) != nil
      end
    end)
  end

  @doc """
  Get or create contact for phone number

  ## Examples

      iex> get_contact_for_phone_number("12345768")
      %Contact{}

  """
  def get_contact_for_phone_number(phone_number) do
    case Repo.get_by(Contact, phone_number: phone_number) do
      nil ->
        create_contact_for_phone_number(phone_number)

      contact ->
        contact
    end
  end

  @doc """
  Create new contact for phone number

  ## Examples

      iex> create_contact_for_phone_number("12345768")
      %Contact{}

  """
  def create_contact_for_phone_number(phone_number) do
    values =
      case search_defaults(phone_number) do
        nil -> %{phone_number: phone_number, action: "allow"}
        default -> %{phone_number: phone_number, action: default.action, name: default.name}
      end

    {:ok, contact} = create_contact(values)
    contact
  end

  @doc """
  Convert action into user friendly display value
  """
  def show_action(action) do
    result =
      Enum.find(@actions, fn
        {_, ^action} -> true
        _ -> false
      end)

    case result do
      {word, _} -> word
      _ -> "Unknown (#{action})"
    end
  end

  @doc """
  Get phone call statistics from list of contacts
  """
  def get_phone_call_stats_for_contacts(contacts) do
    contact_ids = Enum.map(contacts, fn c -> c.id end)

    query =
      from p in PhoneCall,
        group_by: [p.contact_id],
        join: c in Contact,
        where: c.id == p.contact_id and c.id in ^contact_ids,
        select: {p.contact_id, count(p.id)}

    Repo.all(query) |> Enum.into(%{})
  end
end
