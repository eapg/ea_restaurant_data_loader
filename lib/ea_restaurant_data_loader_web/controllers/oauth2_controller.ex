defmodule EaRestaurantDataLoaderWeb.Controllers.Oauth2Controller do
  use EaRestaurantDataLoaderWeb, :controller
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Lib.Services.Oauth2Service
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest

  def login(conn, _params) do
    [client_id, client_secret] =
      try do
        [basic_auth | _] = conn |> get_req_header("authorization")

        Oauth2Util.extract_client_credentials_from_basic_auth(basic_auth)

      rescue
        _ in MatchError -> raise BadRequest
      end

    {_, login_json_response} =
      Oauth2Service.login_client(client_id, client_secret) |> ApplicationUtil.parse_to_json()

    send_resp(conn, :ok, login_json_response)
  end
end
