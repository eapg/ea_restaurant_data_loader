defmodule EaRestaurantDataLoaderWeb.Plugs.SecurityRoutePlug do
  import Plug.Conn

  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util

  def init(opts), do: opts

  def call(conn, _) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    token = get_token(conn)

    {{scopes_status, _}, {roles_status, _}} =
      Oauth2Util.validate_roles_and_scopes(token, secret_key, conn)

    case {scopes_status, roles_status} do
      {:ok, :ok} ->
        conn

      _ ->
        raise UnauthorizedRouteError
    end
  end

  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> raise UnauthorizedRouteError
    end
  end
end
