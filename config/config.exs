# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ea_restaurant_data_loader,
  ecto_repos: [EaRestaurantDataLoader.Repo]

# Configures the endpoint
config :ea_restaurant_data_loader, EaRestaurantDataLoaderWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JNwT3buUb+oQOxwlW6P2iXdBK42B1D/XBdT3dzOJuErpL9sJyNGmvqd3htDjA4fu",
  render_errors: [view: EaRestaurantDataLoaderWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: EaRestaurantDataLoader.PubSub,
  live_view: [signing_salt: "/oRwdZzJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
import_config "#{Mix.env()}.secret.exs"

config :ea_restaurant_data_loader, password_encoding_type: :base64
