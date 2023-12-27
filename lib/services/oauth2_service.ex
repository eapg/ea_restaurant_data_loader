defmodule EaRestaurantDataLoader.Lib.Services.Oauth2Service do
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.Lib.Entities.AppClient
  alias EaRestaurantDataLoader.Lib.Entities.AppAccessToken
  alias EaRestaurantDataLoader.Lib.Entities.AppRefreshToken
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Constants.Status
  alias EaRestaurantDataLoader.Lib.Constants.Oauth2
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.PasswordEncoder
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil

  def login_client(client_id, client_secret) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    client = get_client_by_client_id_and_entity_status(client_id, Status.active())

    validate_client_credentials(client, client_secret)

    [client_scope | _] = client.scopes

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

  def refresh_token(refresh_token, access_token, client_id, client_secret) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    client = get_client_by_client_id_and_entity_status(client_id, Status.active())

    [client_scope | _] = client.scopes
    validate_client_credentials(client, client_secret)

    case Oauth2Util.validate_token(access_token, secret_key) do
      {:ok, _} ->
        %{
          :client_name => client.client_name,
          :access_token => access_token,
          :refresh_token => refresh_token,
          :scopes => client_scope.scope,
          :expires_in => Oauth2Util.get_expiration_time_in_seconds(refresh_token, secret_key)
        }

      {:error, _} ->
        {:ok, _} = Oauth2Util.validate_token(refresh_token, secret_key)

        app_refresh_token = get_app_refresh_token_by_token_and_client_id(refresh_token, client.id)

        new_access_token =
          Oauth2Util.build_client_credentials_token(
            client.client_name,
            client_scope.scope,
            client.access_token_expiration_time,
            secret_key
          )

        delete_access_token_by_app_refresh_token_id(app_refresh_token.id)

        %{
          :client_name => client.client_name,
          :access_token => new_access_token,
          :refresh_token => refresh_token,
          :scopes => client_scope.scope,
          :expires_in => client.access_token_expiration_time
        }
    end
  end

  defp validate_client_credentials(client, client_secret) do
    validated_client =
      case client do
        %AppClient{} ->
          client

        _ ->
          raise InvalidCredentialsError
      end

    password_struct =
      ApplicationUtil.build_password_type_from_env(client_secret, validated_client.client_secret)

    case PasswordEncoder.validate_password(password_struct) do
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

  defp get_app_refresh_token_by_token_and_client_id(refresh_token, app_client_id),
    do: Repo.get_by(AppRefreshToken, token: refresh_token, app_client_id: app_client_id)

  defp delete_access_token_by_app_refresh_token_id(app_refresh_token_id),
    do:
      Repo.get_by(AppAccessToken, refresh_token_id: app_refresh_token_id)
      |> Repo.delete()

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
