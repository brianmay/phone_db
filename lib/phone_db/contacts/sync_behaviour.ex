defmodule PhoneDb.Contacts.SyncBehaviour do
  @moduledoc "Behavior to update a contact"
  alias PhoneDb.Contacts.Contact

  @callback update_contact(%Contact{}) :: :ok | {:error, atom()}
end
