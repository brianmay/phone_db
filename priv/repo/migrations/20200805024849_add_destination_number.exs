defmodule PhoneDb.Repo.Migrations.AddDestinationNumber do
  use Ecto.Migration

  def change do
    alter table("phone_calls") do
      add :destination_number, :string
    end
  end
end
