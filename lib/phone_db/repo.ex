defmodule PhoneDb.Repo do
  use Ecto.Repo,
    otp_app: :phone_db,
    adapter: Ecto.Adapters.Postgres
end
