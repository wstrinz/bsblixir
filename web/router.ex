defmodule BSB.Router do
  use BSB.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    resources "/stories", BSB.StoryController, except: [:new, :edit]
    resources "/feeds", BSB.FeedController, except: [:new, :edit]

    post "/stories/:id", BSB.StoryController, :update
  end

  scope "/", BSB do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", BSB do
  #   pipe_through :api
  # end
end
