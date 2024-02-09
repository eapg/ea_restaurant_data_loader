import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ea_restaurant_data_loader, EaRestaurantDataLoader.Repo,
  username: "postgres",
  password: "1234",
  database: "ea_restaurant_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Configure your database for mongoDB
config :ea_restaurant_data_loader, EaRestaurantDataLoader.MongoRepo,
  url: "mongodb://localhost:27017/ea_restaurant_data_loader_test",
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ea_restaurant_data_loader, EaRestaurantDataLoaderWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning
