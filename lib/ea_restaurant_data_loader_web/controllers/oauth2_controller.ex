defmodule EaRestaurantDataLoaderWeb.Controllers.Oauth2Controller do
  use EaRestaurantDataLoaderWeb, :controller
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Lib.Services.Oauth2Service
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest
  alias EaRestaurantDataLoader.Lib.Constants.Oauth2

  def login_new(conn, _params) do

    [client_id, client_secret] =
      try do
        [basic_auth | _] = conn |> get_req_header("authorization")

        Oauth2Util.extract_client_credentials_from_basic_auth(basic_auth)
      rescue
        _ in MatchError -> raise BadRequest
      end

    login_credentials = conn.body_params
    %{"grant_type" => grant_type} = login_credentials

    client_credential_grand_type = Oauth2.client_credentials()
    user_credential_grand_type = Oauth2.password()

    {_, login_json_response} = Oauth2Service.login_new(%{
        client_id: client_id,
        client_secret: client_secret,
        username: Map.get(login_credentials, "username"),
        password: Map.get(login_credentials, "password"),
        grant_type: grant_type
      })
      |> ApplicationUtil.parse_to_json()

    send_resp(conn, :ok, login_json_response)
  end

  def login(conn, _params) do

    [client_id, client_secret] =
      try do
        [basic_auth | _] = conn |> get_req_header("authorization")

        Oauth2Util.extract_client_credentials_from_basic_auth(basic_auth)
      rescue
        _ in MatchError -> raise BadRequest
      end

    login_credentials = conn.body_params

    client_credential_grand_type = Oauth2.client_credentials()
    user_credential_grand_type = Oauth2.password()

    {_, login_json_response} =
      case login_credentials["grant_type"] do
        ^client_credential_grand_type ->
          Oauth2Service.login_client(client_id, client_secret) |> ApplicationUtil.parse_to_json()

        ^user_credential_grand_type ->
          Oauth2Service.login_user(
            client_id,
            client_secret,
            login_credentials["username"],
            login_credentials["password"]
          )
          |> ApplicationUtil.parse_to_json()
      end

    send_resp(conn, :ok, login_json_response)
  end

  def refresh_token(conn, _params) do
    %{
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "client_id" => client_id,
      "client_secret" => client_secret
    } = conn.body_params

    {_, refresh_token_json_response} =
      Oauth2Service.refresh_token(refresh_token, access_token, client_id, client_secret)
      |> ApplicationUtil.parse_to_json()

    send_resp(conn, :ok, refresh_token_json_response)
  end
end
