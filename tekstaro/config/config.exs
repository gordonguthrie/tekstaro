# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tekstaro,
  ecto_repos: [Tekstaro.Repo]

# Configures the endpoint
config :tekstaro, TekstaroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XNHpxU9VDLDwKB+q7TZfRJWPd5O1e1LBltio1p7pkD2ztPQSVSgCOy6SeYKhJ0eq",
  render_errors: [view: TekstaroWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tekstaro.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :tekstaro, TekstaroWeb.Gettext, default_locale: "eo", locales: ~w(en eo)
