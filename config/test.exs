use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phone_db, PhoneDbWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phone_db, PhoneDb.Repo,
  database: "phone_db_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: "/q7S9SP028A/BbWqkiisc5qZXbBWQFg8+GSTkflTAfRw/K9jCzJKWpSWvWUEoUU4"
