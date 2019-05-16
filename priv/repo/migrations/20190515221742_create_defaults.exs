defmodule PhoneDb.Repo.Migrations.CreateDefaults do
  use Ecto.Migration

  def change do
    create table(:defaults) do
      add :order, :integer
      add :regexp, :string
      add :name, :string
      add :action, :string

      timestamps(type: :timestamptz)
    end
  end
end
