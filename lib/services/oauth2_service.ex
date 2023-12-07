defmodule EaRestaurantDataLoader.Oauth2Service do
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.AppClient
  alias EaRestaurantDataLoader.AppClientScope
  alias EaRestaurantDataLoader.AppAccessToken
  alias EaRestaurantDataLoader.AppRefreshToken
  alias EaRestaurantDataLoader.Oauth2Util
  alias EaRestaurantDataLoader.Status
  alias EaRestaurantDataLoader.Oauth2
  alias EaRestaurantDataLoader.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.Base64
  alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.PasswordEncoder
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  import Ecto.Query

  def login_client(client_id, client_secret) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    client = get_client_by_client_id_and_entity_status(client_id, Status.active())

    [client_scope | _] = client.scopes

    validate_client_credentials(client, client_secret, Status.active())

    access_token =
      Oauth2Util.build_client_credentials_token(
        client.client_name,
        client_scope.scope,
        client.access_token_expiration_time,
        secret_key
      )

    refresh_token =
      Oauth2Util.build_client_credentials_token(
        client.client_name,
        client_scope.scope,
        client.refresh_token_expiration_time,
        secret_key
      )

    {:ok, persisted_refresh_token} =
      create_refresh_token(refresh_token, client, Oauth2.client_credentials())

    {:ok, _} = create_access_token(access_token, persisted_refresh_token)

    %{
      :client_name => client.client_name,
      :access_token => access_token,
      :refresh_token => refresh_token,
      :scopes => client_scope.scope,
      :expires_in => client.access_token_expiration_time
    }
  end

  defp validate_client_credentials(client, client_secret, entity_status) do
    password = ApplicationUtil.build_password_type_from_env(client_secret, client.client_secret)

    case PasswordEncoder.validate_password(password) do
      true ->
        {:ok}

      false ->
        raise InvalidCredentialsError
    end
  end

  defp get_client_by_client_id_and_entity_status(client_id, entity_status),
    do:
      Repo.get_by(AppClient, client_id: client_id, entity_status: entity_status)
      |> Repo.preload([:scopes])

  defp create_access_token(access_token, persisted_refresh_token),
    do:
      %AppAccessToken{}
      |> AppAccessToken.changeset(%{
        token: access_token,
        refresh_token_id: persisted_refresh_token.id
      })
      |> Repo.insert()

  defp create_refresh_token(refresh_token, client, grant_type),
    do:
      %AppRefreshToken{}
      |> AppRefreshToken.changeset(%{
        token: refresh_token,
        app_client_id: client.id,
        grant_type: grant_type
      })
      |> Repo.insert()
end
