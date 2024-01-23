defmodule EaRestaurantDataLoader.Lib.Services.Oauth2Service do
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.Lib.Entities.User
  alias EaRestaurantDataLoader.Lib.Entities.AppClient
  alias EaRestaurantDataLoader.Lib.Entities.AppAccessToken
  alias EaRestaurantDataLoader.Lib.Entities.AppRefreshToken
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Constants.Status
  alias EaRestaurantDataLoader.Lib.Constants.Oauth2
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.PasswordEncoder
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.TokenExpiredError

  def login(%{
        grant_type: grant_type = "CLIENT_CREDENTIALS",
        client_id: client_id,
        client_secret: client_secret
      }) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    client = get_client_by_client_id_and_entity_status(client_id, Status.active())

    validate_client_credentials(client, client_secret)

    [client_scope | _] = client.scopes

    access_token =
      Oauth2Util.build_token(%{grant_type: grant_type}, %{
        client_name: client.client_name,
        scopes: client_scope.scope,
        exp_time: client.access_token_expiration_time,
        secret_key: secret_key
      })

    refresh_token =
      Oauth2Util.build_token(%{grant_type: grant_type}, %{
        client_name: client.client_name,
        scopes: client_scope.scope,
        exp_time: client.refresh_token_expiration_time,
        secret_key: secret_key
      })

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

  def login(%{
        grant_type: grant_type = "PASSWORD",
        client_id: client_id,
        client_secret: client_secret,
        username: username,
        password: password
      }) do
    secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

    client = get_client_by_client_id_and_entity_status(client_id, Status.active())

    validate_client_credentials(client, client_secret)

    [client_scope | _] = client.scopes

    user = get_user_by_username_and_entity_status(username, Status.active())

    validate_user_credentials(user, password)

    access_token =
      Oauth2Util.build_token(%{grant_type: grant_type}, %{
        client_name: client.client_name,
        user: user,
        scopes: client_scope.scope,
        exp_time: client.access_token_expiration_time,
        secret_key: secret_key
      })

    refresh_token =
      Oauth2Util.build_token(%{grant_type: grant_type}, %{
        client_name: client.client_name,
        user: user,
        scopes: client_scope.scope,
        exp_time: client.refresh_token_expiration_time,
        secret_key: secret_key
      })

    {:ok, persisted_refresh_token} =
      create_refresh_token(refresh_token, client, Oauth2.client_credentials())

    {:ok, _} = create_access_token(access_token, persisted_refresh_token)

    %{
      :client_name => client.client_name,
      :access_token => access_token,
      :refresh_token => refresh_token,
      :scopes => client_scope.scope,
      :expires_in => client.access_token_expiration_time,
      :user => user
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
        case Oauth2Util.validate_token(refresh_token, secret_key) do
          {:ok, _} ->
            app_refresh_token =
              get_app_refresh_token_by_token_and_client_id(refresh_token, client.id)

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

          {:error, _} ->
            raise TokenExpiredError
        end
    end
  end

  defp validate_user_credentials(user, password) do
    validated_user =
      case user do
        %User{} ->
          user

        _ ->
          raise InvalidCredentialsError
      end

    password_struct =
      ApplicationUtil.build_password_type_from_env(password, validated_user.password)

    case PasswordEncoder.validate_password(password_struct) do
      true ->
        {:ok}

      false ->
        raise InvalidCredentialsError
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

  defp get_user_by_username_and_entity_status(username, entity_status),
    do: Repo.get_by(User, username: username, entity_status: entity_status)

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
