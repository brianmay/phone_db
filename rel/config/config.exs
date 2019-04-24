use Mix.Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :phone_db, PhoneDbWeb.Endpoint,
  http: [port: port],
  url: [host: "localhost", port: port],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.get_env("SIGNING_SALT")
  ]

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: System.get_env("GUARDIAN_SECRET")
