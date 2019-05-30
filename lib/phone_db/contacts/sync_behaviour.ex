defmodule PhoneDb.Contacts.SyncBehaviour do
  alias PhoneDb.Contacts.Contact

  @callback update_contact(%Contact{}) :: :ok | {:error, atom()}
end
