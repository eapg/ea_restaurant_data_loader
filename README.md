# ea_restaurant_data_loader

ea_restaurant_data_loader is a microservice as part of [ea_restaurant](https://github.com/eapg/EA_RESTAURANT) project to load data into database from an excel file using the functional programming language elixir. This service will load data into database to feed products, inventory, inventory_ingredients, chefs tablets, etc. Also it is good to mention that the service will load massive data into the database with the particularity that it doesn't interrupt the flow of the project, and it will not sacrifice performs of the main application.  

The main objective of this project is the introduction of functional programming with elixir and its web framework phoenix. This project will impact the whole application since it works in asynchronous way it didn't depend of the flow of the whole app. Also This project can improve the whole application as the functional programming can offer several benefits such as improved readability and maintainability, enhance testability and debugging, and increase performance and scalability.

## Project Setup

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

In order to have the phoenix server ready it’s good to fetch and install dependencies running the command:

* `mix deps.get`

Note: It is important before to install the dependencies to install a C compiler to be able to compile `bcrypt_elixir` dependency, follow the following
steps:
* Install a recent version of [Visual C++ Build Tools](https://visualstudio.microsoft.com/downloads/) (On the download page, click on tools for Visual Studio and then you will see the link for the build tools for visual studio 2022)

* Run the visual studio tools and install de desktop C++ developer package

* After installing the visual C++ build tools open the `run` command and type the follogin command(make sure that the path and version number are correct):
    `cmd /K "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat" amd64`


This should open up a command prompt with the necesary enviroment variables set, and from which you will be able to run the commands `mix compile`, `mix deps.compile` and `mix test`. note:cd project path to run the commands above.

If you need additional details you can look at : [bcrypt_elixir,Requirements](https://github.com/riverrun/comeonin/wiki/Requirements)

After dependencies are installed we are ready to compile the project, run tests or run the Phoenix server, running the commands:

* `mix compile` for compile the project
* `mix test` for run all test
* `mix phx.server` for run phoenix server


### Migrations

In order to run migrations in the specific enviroment it is neccessary to set the enviroment in the `mix.exs` file changing the line `start_permanent: Mix.env() == :prod` where you can choose the enviroment changing `:prod` by `:dev` or `:test` depending in which enviroment you want to run migrations.

After choose the desire enviroment you can run the command : `mix ecto.migrate`