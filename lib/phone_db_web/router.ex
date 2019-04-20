defmodule PhoneDbWeb.Router do
  use PhoneDbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoneDbWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/phone_calls", PhoneCallController, :index
    resources "/contacts", ContactController
  end

  scope "/api", PhoneDbWeb do
    pipe_through :api
    post "/incoming_call", ApiController, :incoming_call
  end
end
