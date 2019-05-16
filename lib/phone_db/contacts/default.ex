defmodule PhoneDb.Contacts.Default do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime, usec: true]

  schema "defaults" do
    field :action, :string
    field :name, :string
    field :order, :integer
    field :regexp, :string

    timestamps()
  end

  @doc false
  def changeset(default, attrs) do
    default
    |> cast(attrs, [:order, :regexp, :name, :action])
    |> validate_required([:order, :regexp, :name, :action])
  end
end
