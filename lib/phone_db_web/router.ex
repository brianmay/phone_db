defmodule PhoneDbWeb.Router do
  use PhoneDbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
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

    plug BasicAuth,
      callback: &PhoneDb.Users.Auth.find_by_username_and_password/3,
      realm: "Phone DB",
      custom_response: &PhoneDb.Users.Auth.unauthorized_response/1
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
  end

  scope "/", PhoneDbWeb do
    pipe_through [:browser, :auth, :ensure_admin]

    resources "/users", UserController
  end

  scope "/api", PhoneDbWeb do
    pipe_through :api
    post "/incoming_call", ApiController, :incoming_call
  end
end
