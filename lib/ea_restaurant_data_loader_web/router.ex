defmodule EaRestaurantDataLoaderWeb.Router do
  use EaRestaurantDataLoaderWeb, :router
  use Plug.ErrorHandler
  alias EaRestaurantDataLoaderWeb.ErrorHandlers.CustomErrorHandler
  alias EaRestaurantDataLoaderWeb.Plugs.SecurityRoutePlug

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :protected_api do
    plug(:accepts, ["json"])
    plug(SecurityRoutePlug)
  end

  scope "/", EaRestaurantDataLoaderWeb.Controllers do
    pipe_through([:api])

    post("/login", Oauth2Controller, :login)

  end

  scope "/", EaRestaurantDataLoaderWeb.Controllers do
    pipe_through([:protected_api])

    post("/refresh_token", Oauth2Controller, :refresh_token)
    get("/products", ProductController, :get_products)
    post("/products/import", ProductController, :import_products)
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    {status, message} = CustomErrorHandler.handle(reason)
    send_resp(conn, status, message)
  end
end
