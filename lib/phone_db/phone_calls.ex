defmodule PhoneDb.PhoneCalls do
  @moduledoc """
  The PhoneCalls context.
  """

  import Ecto.Query, warn: false
  alias PhoneDb.Repo

  alias PhoneDb.Contacts.PhoneCall

  @doc """
  Returns the list of phone_calls.

  ## Examples

      iex> list_phone_calls()
      [%PhoneCall{}, ...]

  """
  def list_phone_calls do
    Repo.all(PhoneCall)
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
  Updates a phone_call.

  ## Examples

      iex> update_phone_call(phone_call, %{field: new_value})
      {:ok, %PhoneCall{}}

      iex> update_phone_call(phone_call, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_phone_call(%PhoneCall{} = phone_call, attrs) do
    phone_call
    |> PhoneCall.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PhoneCall.

  ## Examples

      iex> delete_phone_call(phone_call)
      {:ok, %PhoneCall{}}

      iex> delete_phone_call(phone_call)
      {:error, %Ecto.Changeset{}}

  """
  def delete_phone_call(%PhoneCall{} = phone_call) do
    Repo.delete(phone_call)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phone_call changes.

  ## Examples

      iex> change_phone_call(phone_call)
      %Ecto.Changeset{source: %PhoneCall{}}

  """
  def change_phone_call(%PhoneCall{} = phone_call) do
    PhoneCall.changeset(phone_call, %{})
  end
end
