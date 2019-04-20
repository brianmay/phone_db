defmodule PhoneDb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :phone_number, :string, null: false
      add :name, :string, null: true
      add :action, :string, null: false

      timestamps(type: :timestamptz)
    end

    create unique_index(:contacts, [:phone_number])
  end
end
