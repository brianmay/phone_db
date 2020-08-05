defmodule PhoneDb.Contacts.PhoneCall do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime, usec: true]

  schema "phone_calls" do
    field :action, :string
    belongs_to :contact, PhoneDb.Contacts.Contact
    field :destination_number, :string

    timestamps()
  end

  @doc false
  def changeset(phone_call, attrs) do
    phone_call
    |> cast(attrs, [:action, :destination_number])
    |> validate_required([:action, :destination_number])
  end
end
