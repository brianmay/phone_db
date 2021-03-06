# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :phone_db,
  ecto_repos: [PhoneDb.Repo],
  actions: [
    {"Allow", "allow"},
    {"Voicemail", "voicemail"}
  ],
  sync_services: [PhoneDb.Contacts.Ldap],
  build_date: System.get_env("BUILD_DATE"),
  vcs_ref: System.get_env("VCS_REF")

config :phone_db, PhoneDb.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# Configures the endpoint
config :phone_db, PhoneDbWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: PhoneDbWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PhoneDb.PubSub,
  live_view: [
    signing_salt: System.get_env("SIGNING_SALT")
  ]

config :paddle, Paddle,
  host: System.get_env("LDAP_SERVER"),
  base: System.get_env("LDAP_BASE_DN"),
  account_subdn: "",
  port: 389,
  ssl: false,
  username: System.get_env("LDAP_USERNAME"),
  password: System.get_env("LDAP_USER_PASSWORD"),
  timeout: 1000,
  schema_files: ["../../core.schema"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: System.get_env("GUARDIAN_SECRET")

if System.get_env("IPV6") != nil do
  config :paddle, Paddle, ipv6: true
end

config :libcluster,
  topologies: []

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
