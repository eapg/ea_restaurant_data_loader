defmodule EaRestaurantDataLoader.Oauth2ServiceTest do
  use EaRestaurantDataLoader.RepoCase
  alias EaRestaurantDataLoader.Oauth2Service
  alias EaRestaurantDataLoader.AppClientFixture
  alias EaRestaurantDataLoader.UserFixture
  alias EaRestaurantDataLoader.AppClientScopeFixture
  alias EaRestaurantDataLoader.Oauth2Util
  alias EaRestaurantDataLoader.Test.Fixtures.AppAccessTokenFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppRefreshTokenFixture
  alias EaRestaurantDataLoader.Oauth2

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
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          0,
          secret_key
        )

      refresh_token =
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          client.refresh_token_expiration_time,
          secret_key
        )

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, persisted_access_token} =
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
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          client.access_token_expiration_time,
          secret_key
        )

      refresh_token =
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          client.refresh_token_expiration_time,
          secret_key
        )

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, persisted_access_token} =
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
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          0,
          secret_key
        )

      expired_refresh_token =
        Oauth2Util.build_client_credentials_token(
          client.client_name,
          scopes.scope,
          0,
          secret_key
        )

      {:ok, persisted_refresh_token} =
        AppRefreshTokenFixture.build_and_insert_app_refresh_token(
          expired_refresh_token,
          Oauth2.client_credentials(),
          client.id
        )

      {:ok, persisted_access_token} =
        AppAccessTokenFixture.build_and_insert_app_access_token(
          expired_access_token,
          persisted_refresh_token.id
        )

      assert_raise(
        MatchError,
        ~r/no match of right hand side value: {:error, "Invalid token"}/,
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
  end
end
