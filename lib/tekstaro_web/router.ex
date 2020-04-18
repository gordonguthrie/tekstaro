defmodule TekstaroWeb.Router do
  use TekstaroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SetLocale, gettext: TekstaroWeb.Gettext, default_locale: "en", cookie_key: "project_locale",
      additional_locales: ["eo"]
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug SetLocale, gettext: TekstaroWeb.Gettext, default_locale: "en", cookie_key: "project_locale",
      additional_locales: ["eo"]
  end

  scope "/:locale", TekstaroWeb do
    pipe_through :browser

    get       "/",              PageController,    :index
    get       "/upload",        UploadController,  :index
    get       "/browse",        BrowseController,  :index
    resources "/registrations", UserController,    only: [:create, :new]
    get       "/sign-in",       SessionController, :new
    post      "/sign-in",       SessionController, :login
    delete    "/sign-out",      SessionController, :logout
  end

  scope "/", TekstaroWeb do
    pipe_through :browser

    get "/", PageController, :chose_language, as: :redirect_frontpage
  end

  # Other scopes may use custom stacks.
  scope "/api", TekstaroWeb do
    pipe_through :api
    post "/upload",  UploadController, :upload
    post "/search",  SearchController, :search
    post "/parse",   SearchController, :parse
    post "/browse",  SearchController, :browse
  end

end
