defmodule TekstaroWeb.Router do
  use TekstaroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SetLocale, gettext: TekstaroWeb.Gettext, default_locale: "eo"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/:locale", TekstaroWeb do
    pipe_through :browser

    get "/",       PageController,   :index
    get "/upload", UploadController, :index
  end

  scope "/", TekstaroWeb do
    pipe_through :browser

    get "/", PageController, :redirect_frontpage
  end


  # Other scopes may use custom stacks.
   scope "/api", TekstaroWeb do
     pipe_through :api

     post "/upload", UploadController, :upload
   end
end
