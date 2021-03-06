# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :connect_four_backend,
  namespace: ConnectFourBackend,
  ecto_repos: [ConnectFourBackend.Repo]

# Configures the endpoint
config :connect_four_backend, ConnectFourBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+zzd78KL+kIFlkO8W5xCXiA62jF4+fpvNDGzsZjvUjKlWGOHpTmYwpg5YGPwiRAY",
  render_errors: [view: ConnectFourBackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ConnectFourBackend.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
