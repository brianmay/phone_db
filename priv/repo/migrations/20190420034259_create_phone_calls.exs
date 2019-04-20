defmodule PhoneDb.Repo.Migrations.CreatePhoneCalls do
  use Ecto.Migration

  def change do
    create table(:phone_calls) do
      add :action, :string, null: false
      add :contact_id, references(:contacts), null: false

      timestamps(type: :timestamptz)
    end
  end
end
