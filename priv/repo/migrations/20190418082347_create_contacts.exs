defmodule PhoneDb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :phone_number, :string
      add :name, :string
      add :action, :string

      timestamps()
    end

  end
end
