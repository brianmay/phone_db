defmodule PhoneDbWeb.ContactController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Contacts
  alias PhoneDb.Contacts.Contact

  defp get_actions, do: Application.get_env(:phone_db, :actions)

  def new(conn, _params) do
    changeset = Contacts.change_contact(%Contact{})
    render(conn, "new.html", changeset: changeset, actions: get_actions(), active: "contacts")
  end

  def create(conn, %{"contact" => contact_params}) do
    case Contacts.create_contact(contact_params) do
      {:ok, contact} ->
        conn
        |> put_flash(:info, "Contact created successfully.")
        |> redirect(to: Routes.show_contact_path(conn, :index, contact))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, actions: get_actions(), active: "contacts")
    end
  end

  def edit(conn, %{"id" => id}) do
    contact = Contacts.get_contact!(id)
    changeset = Contacts.change_contact(contact)

    render(conn, "edit.html",
      contact: contact,
      changeset: changeset,
      actions: get_actions(),
      active: "contacts"
    )
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Contacts.get_contact!(id)

    case Contacts.update_contact(contact, contact_params) do
      {:ok, contact} ->
        conn
        |> put_flash(:info, "Contact updated successfully.")
        |> redirect(to: Routes.show_contact_path(conn, :index, contact))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          contact: contact,
          changeset: changeset,
          actions: get_actions(),
          active: "contacts"
        )
    end
  end
end
