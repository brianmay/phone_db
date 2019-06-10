use Mix.Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :phone_db, PhoneDb.Repo,
  url: System.get_env("DATABASE_URL")

config :phone_db, PhoneDbWeb.Endpoint,
  http: [port: port, ip: {0, 0, 0, 0, 0, 0, 0, 0}],
  url: [host: System.get_env("HOST"), port: port],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.get_env("SIGNING_SALT")
  ]

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :paddle, Paddle,
  host: System.get_env("LDAP_SERVER"),
  base: System.get_env("LDAP_BASE_DN"),
  account_subdn: "",
  port: 389,
  ssl: false,
  username: System.get_env("LDAP_USERNAME"),
  password: System.get_env("LDAP_USER_PASSWORD")

if System.get_env("IPV6") != nil do
  config :phone_db, PhoneDb.Repo, socket_options: [:inet6]
  config :paddle, Paddle, ipv6: true
end
