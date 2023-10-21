import Config

config :phone_db,
  phone_auth: [
    username: System.get_env("PHONE_USERNAME"),
    password: System.get_env("PHONE_PASSWORD")
  ],
  oidc: %{
    discovery_document_uri: System.get_env("OIDC_DISCOVERY_URL"),
    client_id: System.get_env("OIDC_CLIENT_ID"),
    client_secret: System.get_env("OIDC_CLIENT_SECRET"),
    scope: System.get_env("OIDC_AUTH_SCOPE")
  }

config :phone_db, PhoneDb.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

port = String.to_integer(System.get_env("PORT") || "4000")
http_url = System.get_env("HTTP_URL")
http_uri = URI.parse(http_url)

config :phone_db, PhoneDbWeb.Endpoint,
  http: [
    :inet6,
    port: port,
    protocol_options: [max_header_value_length: 8096]
  ],
  url: [scheme: http_uri.scheme, host: http_uri.host, port: http_uri.port],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  live_view: [
    signing_salt: System.get_env("SIGNING_SALT")
  ]

config :phone_db, PhoneDb.Users.Guardian,
  issuer: "phone_db",
  secret_key: System.get_env("GUARDIAN_SECRET")

config :penguin_paddle, Paddle,
  host: System.get_env("LDAP_SERVER"),
  base: System.get_env("LDAP_BASE_DN"),
  account_subdn: "",
  port: 389,
  ssl: false,
  username: System.get_env("LDAP_USERNAME"),
  password: System.get_env("LDAP_USER_PASSWORD")

if System.get_env("IPV6") != nil do
  config :penguin_paddle, Paddle, ipv6: true
end

config :plugoid,
  auth_cookie_store_opts: [
    signing_salt: System.get_env("SIGNING_SALT")
  ],
  state_cookie_store_opts: [
    signing_salt: System.get_env("SIGNING_SALT")
  ]

config :os_mon,
  start_disksup: false
