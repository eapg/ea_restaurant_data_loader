# ea_restaurant_data_loader

ea_restaurant_data_loader is a microservice as part of [ea_restaurant](https://github.com/eapg/EA_RESTAURANT) project to load data into database from an excel file using the functional programming language elixir. This service will load data into database to feed products, inventory, inventory_ingredients, chefs tablets, etc. Also it is good to mention that the service will load massive data into the database with the particularity that it doesn't interrupt the flow of the project, and it will not sacrifice performs of the main application.  

The main objective of this project is the introduction of functional programming with elixir and its web framework phoenix. This project will impact the whole application since it works in asynchronous way it didn't depend of the flow of the whole app. Also This project can improve the whole application as the functional programming can offer several benefits such as improved readability and maintainability, enhance testability and debugging, and increase performance and scalability.

## Project Setup

### Dependencies

In order to run the project, we will need few dependencies to be installed:

- [Erlang/OTP](https://www.erlang.org)
- [Elixir](https://elixir-lang.org)
- [Postgres SQL] (https://www.postgresql.org)

### Build an application with Phoenix

In Order to build a Phoenix application, we will need a few dependencies installed in our Operating System:

- The [Erlang/OTP](https://www.erlang.org/downloads) and the [Elixir](https://elixir-lang.org/install.html#windows) programming language
- a database - Phoenix recommends PostgreSQL , but you can pick others or not use a database at all
- and other optional packages

In order to get a Phoenix app running and to install any extra dependencies we might need to install Hex.

Here’s the command to install Hex:

`mix local.hex`

Once we have Elixir and Erlang, we are ready to install Phoenix application generator:

`mix archive.install hex phx_new`

After that the `phx.new` generator is now available to generate new applications. In order to config a database Phoenix applications use another elixir package, called Ecto. Ecto is a toolkit for data mapping and language integrated query for Elixir.

Now we are ready to create our Phoenix application running the following command:

`mix phx.new ea_restaurant_data_loader`

### Local Setup
1. Clone the project:
    ```
    git clone https://github.com/eapg/ea_restaurant_data_loader.git
    ```
2. Go to the project's folder and install dependencies by running:
    ```
    mix deps.get
    ```
3. Setup your environment variables for the project within `config/config.exs`. For example:
    ```
    # Password enconder that will be used
    config :ea_restaurant_data_loader, password_encoding_type: :base64
    ```
4.  Setup your environment variables for `dev` within `config/dev.exs`. For example:
    ```
    # Configure your database
    config :ea_restaurant_data_loader, EaRestaurantDataLoader.Repo,
      username: "postgres",
      password: "1234",
      database: "ea_restaurant",
      hostname: "localhost",
      show_sensitive_data_on_connection_error: true,
      pool_size: 10

    # HTTP Server
    config :ea_restaurant_data_loader, EaRestaurantDataLoaderWeb.Endpoint,
      http: [port: 4000],
      debug_errors: true,
      code_reloader: true,
      check_origin: false,
      watchers: []

    # Default JWT signer
    config :joken, default_signer: "secret"
    ```
5.  Setup your environment variables for `test` within `config/test.exs`. For example:
    ```
    # Configure your database
    config :ea_restaurant_data_loader, EaRestaurantDataLoader.Repo,
      username: "postgres",
      password: "1234",
      database: "ea_restaurant_test#{System.get_env("MIX_TEST_PARTITION")}",
      hostname: "localhost",
      pool: Ecto.Adapters.SQL.Sandbox

    # HTTP Server
    # We don't run a server during test. If one is required,
    # you can enable the server option below.
    config :ea_restaurant_data_loader, EaRestaurantDataLoaderWeb.Endpoint,
      http: [port: 4002],
      server: false
    ```
6.  Select your environment by setting `MIX_ENV` environment variable. You can select between:
    1. `MIX_ENV=dev`
    2. `MIX_ENV=test`
    3. `MIX_ENV=prod`
7. Run migrations:
    ```
    mix ecto.migrate
    ```
8. After setting up the project you will be able to run:
    ```
    # For compiling the project
    mix compile

    # For running tests
    mix test
    
    # For running the http server
    mix phx.server
    ```
