defmodule PhoneDbWeb.Router do
  use PhoneDbWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoneDbWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug PhoneDbWeb.Plug.Auth
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_admin do
    plug Guardian.Plug.EnsureAuthenticated
    plug PhoneDbWeb.Plug.CheckAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug PhoneDbWeb.Plug.AuthUser
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    get "/login", SessionController, :new
    post "/login", SessionController, :login
    post "/logout", SessionController, :logout
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    live "/phone_calls", ListPhoneCallLive, :index
    resources "/contacts", ContactController, only: [:edit, :new, :create, :update]
    live "/contacts", ListContactLive, :index
    live "/contacts/:id", ShowContactLive, :index
    resources "/defaults", DefaultController
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth, :ensure_admin]

    resources "/users", UserController
    get "/users/:id/password", UserController, :password_edit
    put "/users/:id/password", UserController, :password_update

    live_dashboard "/dashboard", metrics: PhoneDbWeb.Telemetry
  end

  scope "/api", PhoneDbWeb do
    pipe_through :api
    post "/incoming_call", ApiController, :incoming_call
  end
end
