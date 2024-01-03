defmodule EaRestaurantDataLoaderWeb.Router do
  use EaRestaurantDataLoaderWeb, :router
  use Plug.ErrorHandler
  alias EaRestaurantDataLoaderWeb.ErrorHandlers.CustomErrorHandler

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", EaRestaurantDataLoaderWeb.Controllers do
    pipe_through([:api])

    post("/login", Oauth2Controller, :login)
  end

  @impl Plug.ErrorHandler
  def handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    {status, message} = CustomErrorHandler.handle(reason)
    send_resp(conn, status, message)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:fetch_session, :protect_from_forgery])
      live_dashboard("/dashboard", metrics: EaRestaurantDataLoaderWeb.Telemetry)
    end
  end
end
