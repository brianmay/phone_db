defmodule PhoneDb.Users.User do
  @moduledoc "User db methods"
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime, usec: true]

  @type t :: %__MODULE__{
          is_admin: boolean,
          is_phone: boolean,
          is_trusted: boolean,
          password: String.t(),
          password_confirmation: String.t(),
          password_hash: binary(),
          username: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :is_admin, :boolean, default: false
    field :is_phone, :boolean, default: false
    field :is_trusted, :boolean, default: false
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :password,
      :password_confirmation,
      :is_admin,
      :is_trusted,
      :is_phone
    ])
    |> validate_required([
      :username,
      :password,
      :password_confirmation,
      :is_admin,
      :is_trusted,
      :is_phone
    ])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    |> put_password_hash
    |> put_change(:password_confirmation, nil)
  end

  @doc false
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :is_admin, :is_trusted, :is_phone])
    |> validate_required([:username, :is_admin, :is_trusted, :is_phone])
    |> unique_constraint(:username)
  end

  @doc false
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> put_password_hash
    |> put_change(:password_confirmation, nil)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_password_hash(changeset), do: changeset
end
