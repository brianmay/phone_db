defmodule PhoneDbWeb.Router do
  use PhoneDbWeb, :router
  import Phoenix.LiveDashboard.Router

  use Plugoid.RedirectURI,
    token_callback: &PhoneDbWeb.TokenCallback.callback/5

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoneDbWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  defmodule PlugoidConfig do
    def common do
      config = Application.get_env(:phone_db, :oidc)

      [
        issuer: config.discovery_document_uri,
        client_id: config.client_id,
        scope: String.split(config.scope, " "),
        client_config: PhoneDbWeb.ClientCallback
      ]
    end
  end

  defp phone_auth(conn, _opts) do
    auth = Application.get_env(:phone_db, :phone_auth)
    Plug.BasicAuth.basic_auth(conn, auth)
  end

  pipeline :auth do
    plug Replug,
      plug: {Plugoid, on_unauthenticated: :pass},
      opts: {PlugoidConfig, :common}
  end

  pipeline :ensure_auth do
    plug Replug,
      plug: {Plugoid, on_unauthenticated: :auth},
      opts: {PlugoidConfig, :common}
  end

  pipeline :ensure_admin do
    plug PhoneDbWeb.Plug.CheckAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :phone_auth
  end

  scope "/health" do
    get "/", PhoneDbWeb.PageController, :health
  end

  live_session :default, on_mount: PhoneDbWeb.InitAssigns do
    scope "/", PhoneDbWeb do
      pipe_through [:browser, :auth]

      get "/", PageController, :index
      post "/logout", PageController, :logout
    end

    scope "/", PhoneDbWeb do
      pipe_through [:browser, :ensure_auth]

      get "/login", PageController, :login
      live "/phone_calls", ListPhoneCallLive, :index
      resources "/contacts", ContactController, only: [:edit, :new, :create, :update]
      live "/contacts", ListContactLive, :index
      live "/contacts/:id", ShowContactLive, :index
      resources "/defaults", DefaultController
    end
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth, :ensure_admin]
    live_dashboard "/dashboard", metrics: PhoneDbWeb.Telemetry
  end

  scope "/api", PhoneDbWeb do
    pipe_through :api
    post "/incoming_call", ApiController, :incoming_call
  end
end
