defmodule BlockPuzzleLiveViewWeb.Router do
  use BlockPuzzleLiveViewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlockPuzzleLiveViewWeb do
    pipe_through :browser

    get "/", PageController, :index

    live "/game", GameLive, session: [:user_id]
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlockPuzzleLiveViewWeb do
  #   pipe_through :api
  # end
end
