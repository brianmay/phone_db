import Config

config :phone_db,
  sync_services: [],
  phone_auth: [
    username: "user",
    password: "some password"
  ],
  oidc: %{
    discovery_document_uri: "",
    client_id: "",
    client_secret: "",
    scope: ""
  }

config :phone_db, PhoneDbWeb.Endpoint, server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :paddle, Paddle, host: "localhost"

# Configure your database
config :phone_db, PhoneDb.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: System.get_env("DATABASE_URL_TEST")

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: "/q7S9SP028A/BbWqkiisc5qZXbBWQFg8+GSTkflTAfRw/K9jCzJKWpSWvWUEoUU4"

config :phone_db, PhoneDbWeb.Endpoint,
  secret_key_base: "oOWDT+7p6JENufDeyMQFLqDMsj1bkVfQT4Navmr5qYem9crHED4jAMr0Stf4aRNt",
  live_view: [
    signing_salt: "6JsXtIwI2Wo64YdWdWIl1UY8fb1i1ggw"
  ]

config :plugoid,
  auth_cookie_store_opts: [
    signing_salt: "/EeCfa85oE1mkAPMo2kPsT5zkCFPveHk"
  ],
  state_cookie_store_opts: [
    signing_salt: "/EeCfa85oE1mkAPMo2kPsT5zkCFPveHk"
  ]
