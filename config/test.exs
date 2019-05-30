use Mix.Config

config :phone_db,
  sync_services: []

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

config :phone_db, PhoneDbWeb.Endpoint,
  secret_key_base: "oOWDT+7p6JENufDeyMQFLqDMsj1bkVfQT4Navmr5qYem9crHED4jAMr0Stf4aRNt",
  live_view: [
    signing_salt: "6JsXtIwI2Wo64YdWdWIl1UY8fb1i1ggw"
  ]
