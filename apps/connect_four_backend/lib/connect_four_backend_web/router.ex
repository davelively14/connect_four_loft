defmodule ConnectFourBackendWeb.Router do
  use ConnectFourBackendWeb, :router

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

  # TODO: remove
  scope "/", ConnectFourBackendWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", ConnectFourBackendWeb do
    pipe_through :api

    resources "/game", GameController, only: [:create]
  end
end
