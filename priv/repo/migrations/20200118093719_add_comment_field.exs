defmodule PhoneDb.Repo.Migrations.AddCommentField do
  use Ecto.Migration

  def change do
    alter table("contacts") do
      add :comments, :string
    end
  end
end
