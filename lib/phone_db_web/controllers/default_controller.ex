defmodule PhoneDbWeb.DefaultController do
  use PhoneDbWeb, :controller

  alias PhoneDb.Contacts
  alias PhoneDb.Contacts.Default

  @actions Application.get_env(:phone_db, :actions)

  def index(conn, _params) do
    defaults = Contacts.list_defaults()
    render(conn, "index.html", defaults: defaults)
  end

  def new(conn, _params) do
    changeset = Contacts.change_default(%Default{})
    render(conn, "new.html", changeset: changeset, actions: @actions)
  end

  def create(conn, %{"default" => default_params}) do
    case Contacts.create_default(default_params) do
      {:ok, default} ->
        conn
        |> put_flash(:info, "Default created successfully.")
        |> redirect(to: Routes.default_path(conn, :show, default))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, actions: @actions)
    end
  end

  def show(conn, %{"id" => id}) do
    default = Contacts.get_default!(id)
    render(conn, "show.html", default: default)
  end

  def edit(conn, %{"id" => id}) do
    default = Contacts.get_default!(id)
    changeset = Contacts.change_default(default)
    render(conn, "edit.html", default: default, changeset: changeset, actions: @actions)
  end

  def update(conn, %{"id" => id, "default" => default_params}) do
    default = Contacts.get_default!(id)

    case Contacts.update_default(default, default_params) do
      {:ok, default} ->
        conn
        |> put_flash(:info, "Default updated successfully.")
        |> redirect(to: Routes.default_path(conn, :show, default))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", default: default, changeset: changeset, actions: @actions)
    end
  end

  def delete(conn, %{"id" => id}) do
    default = Contacts.get_default!(id)
    {:ok, _default} = Contacts.delete_default(default)

    conn
    |> put_flash(:info, "Default deleted successfully.")
    |> redirect(to: Routes.default_path(conn, :index))
  end
end
