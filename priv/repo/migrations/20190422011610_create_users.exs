defmodule PhoneDb.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: true
      add :password_hash, :string, null: true
      add :is_admin, :boolean, default: false, null: true
      add :is_trusted, :boolean, default: false, null: true
      add :is_phone, :boolean, default: false, null: true

      timestamps(type: :timestamptz)
    end

    create unique_index(:users, [:username])
  end
end
