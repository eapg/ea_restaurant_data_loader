defmodule EaRestaurantDataLoader.Test.Lib.Services.Oauth2ServiceTest do
  use EaRestaurantDataLoader.RepoCase
  alias EaRestaurantDataLoader.Lib.Services.Oauth2Service
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientFixture
  alias EaRestaurantDataLoader.Test.Fixtures.UserFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientScopeFixture
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Test.Fixtures.AppAccessTokenFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppRefreshTokenFixture
  alias EaRestaurantDataLoader.Lib.Constants.Oauth2
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.TokenExpiredError

  describe "oauth2 service test" do
    test " client credential login" do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)

      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, app_client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ,WRITE", app_client.id, user)

      login_response = Oauth2Service.login_client("postman001", "postmansecret01")

      {_, access_token_decoded} =
        Oauth2Util.get_token_decoded(login_response.access_token, secret_key)

      %{"clientName" => client_name_value, "scopes" => scopes_value} = access_token_decoded
      assert client_name_value == app_client.client_name
      assert scopes_value == scopes.scope
      assert login_response.expires_in == app_client.access_token_expiration_time
      assert login_response.scopes == scopes.scope
    end

    test " refresh token when expired access token" do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ,WRITE", client.id, user)

      expired_access_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: 0,
          secret_key: secret_key
        })

      refresh_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: client.refresh_token_expiration_time,
          secret_key: secret_key
        })

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, _} =
        AppAccessTokenFixture.build_and_insert_app_access_token(
          expired_access_token,
          persisted_refresh_token.id
        )

      refresh_token_response =
        Oauth2Service.refresh_token(
          refresh_token,
          expired_access_token,
          "postman001",
          "postmansecret01"
        )

      assert expired_access_token != refresh_token_response.access_token
    end

    test " refresh token when not expired access token" do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ,WRITE", client.id, user)

      access_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: client.access_token_expiration_time,
          secret_key: secret_key
        })

      refresh_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: client.refresh_token_expiration_time,
          secret_key: secret_key
        })

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, _} =
        AppAccessTokenFixture.build_and_insert_app_access_token(
          access_token,
          persisted_refresh_token.id
        )

      refresh_token_response =
        Oauth2Service.refresh_token(
          refresh_token,
          access_token,
          "postman001",
          "postmansecret01"
        )

      assert access_token == refresh_token_response.access_token
    end

    test "refresh token when expired refresh token" do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ,WRITE", client.id, user)

      expired_access_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: 0,
          secret_key: secret_key
        })

      expired_refresh_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: 0,
          secret_key: secret_key
        })

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          expired_refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, _} =
        AppAccessTokenFixture.build_and_insert_app_access_token(
          expired_access_token,
          persisted_refresh_token.id
        )

      assert_raise(
        TokenExpiredError,
        ~r/Token expired/,
        fn ->
          Oauth2Service.refresh_token(
            expired_refresh_token,
            expired_access_token,
            "postman001",
            "postmansecret01"
          )
        end
      )
    end

    test "oauth2-login wrong credentials" do
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, _app_client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      assert_raise(
        InvalidCredentialsError,
        ~r/Invalid Credentials/,
        fn ->
          Oauth2Service.login_client("wrong-client-id", "wrong-client-secret")
        end
      )
    end
  end
end
