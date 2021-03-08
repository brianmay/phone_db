defmodule PhoneDbWeb.Router do
  use PhoneDbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug PhoneDb.Users.Pipeline
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_admin do
    plug Guardian.Plug.EnsureAuthenticated
    plug PhoneDb.Users.CheckAdmin
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug PhoneDb.Users.AuthUser
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

    get "/phone_calls", PhoneCallController, :index
    resources "/contacts", ContactController
    resources "/defaults", DefaultController
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth, :ensure_admin]

    resources "/users", UserController
    get "/users/:id/password", UserController, :password_edit
    put "/users/:id/password", UserController, :password_update
  end

  scope "/api", PhoneDbWeb do
    pipe_through :api
    post "/incoming_call", ApiController, :incoming_call
  end
end
