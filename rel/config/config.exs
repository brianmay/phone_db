use Mix.Config

port = String.to_integer(System.get_env("PORT") || "4000")
default_secret_key_base = :crypto.strong_rand_bytes(64) |> Base.encode64

config :phone_db, PhoneDbWeb.Endpoint,
  http: [port: port],
  url: [host: "localhost", port: port],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || default_secret_key_base

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: System.get_env("GUADIAN_SECRET")
