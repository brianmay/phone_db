defmodule PhoneDb.Contacts.Contact do
  @moduledoc "A recorded telephone number"
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime, usec: true]

  schema "contacts" do
    field :action, :string
    field :name, :string
    field :comments, :string
    field :phone_number, :string
    has_many :phone_calls, PhoneDb.Contacts.PhoneCall

    timestamps()
  end

  @doc false
  def create_changeset(contact, attrs) do
    contact
    |> cast(attrs, [:phone_number, :name, :comments, :action])
    |> validate_required([:phone_number, :action])
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :comments, :action])
    |> validate_required([:name, :action])
  end
end
