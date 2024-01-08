defmodule EaRestaurantDataLoaderWeb.Plugs.SecurityRoutePlug do

  import Plug.Conn

  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util

  def init(opts), do: opts

  def call(conn, _) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    get_token(conn) |>
    Oauth2Util.validate_route_protection(secret_key,conn)

  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> raise UnauthorizedRouteError
    end
  end


end
