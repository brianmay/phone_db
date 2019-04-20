defmodule PhoneDb.Contacts.PhoneCall do
  use Ecto.Schema
  import Ecto.Changeset

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
