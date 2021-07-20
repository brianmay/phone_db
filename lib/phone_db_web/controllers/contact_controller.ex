defmodule PhoneDbWeb.ContactController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Contacts
  alias PhoneDb.Contacts.Contact

  alias Phoenix.LiveView

  defp get_actions, do: Application.get_env(:phone_db, :actions)

  def index(conn, params) do
    LiveView.Controller.live_render(conn, PhoneDbWeb.ListContactLive,
      session: %{"query" => Map.get(params, "query")}
    )
  end

  def new(conn, _params) do
    changeset = Contacts.change_contact(%Contact{})
    render(conn, "new.html", changeset: changeset, actions: get_actions(), active: "contacts")
  end

  def create(conn, %{"contact" => contact_params}) do
    case Contacts.create_contact(contact_params) do
      {:ok, contact} ->
        conn
        |> put_flash(:info, "Contact created successfully.")
        |> redirect(to: Routes.contact_path(conn, :show, contact))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, actions: get_actions(), active: "contacts")
    end
  end

  def show(conn, %{"id" => id} = params) do
    LiveView.Controller.live_render(conn, PhoneDbWeb.ShowContactLive,
      session: %{"id" => id, "query" => Map.get(params, "query")}
    )
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
        |> redirect(to: Routes.contact_path(conn, :show, contact))

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
