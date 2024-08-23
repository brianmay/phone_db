# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :phone_db,
  ecto_repos: [PhoneDb.Repo],
  actions: [
    {"Allow", "allow"},
    {"Voicemail", "voicemail"}
  ],
  sync_services: [PhoneDb.Contacts.Ldap],
  build_date: System.get_env("BUILD_DATE"),
  vcs_ref: System.get_env("VCS_REF")

config :phone_db, PhoneDbWeb.Endpoint,
  render_errors: [view: PhoneDbWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: PhoneDb.PubSub

config :penguin_paddle, Paddle,
  timeout: 1000,
  schema_files: [System.get_env("TOP_SRC", "../..") <> "/core.schema"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  topologies: []

config :plugoid,
  auth_cookie_store: Plug.Session.COOKIE,
  auth_cookie_opts: [
    secure: true,
    extra: "SameSite=Lax"
  ],
  state_cookie_opts: [
    secure: true,
    extra: "SameSite=None"
  ]

config :elixir, :time_zone_database, Tz.TimeZoneDatabase
config :tzdata, :autoupdate, :disabled

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
