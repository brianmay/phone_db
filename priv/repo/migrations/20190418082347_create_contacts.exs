defmodule PhoneDb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :phone_number, :string, null: false
      add :name, :string, null: false
      add :action, :string, null: false

      timestamps()
    end

  end
end
