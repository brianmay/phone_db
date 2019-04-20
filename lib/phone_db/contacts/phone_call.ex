defmodule PhoneDb.Contacts.PhoneCall do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime, usec: true]

  schema "phone_calls" do
    field :action, :string
    belongs_to :contact, PhoneDb.Contacts.Contact

    timestamps()
  end

  @doc false
  def changeset(phone_call, attrs) do
    phone_call
    |> cast(attrs, [:action])
    |> validate_required([:action])
  end
end
