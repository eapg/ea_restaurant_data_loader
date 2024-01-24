defmodule EaRestaurantDataLoader.Test.EaRestaurantDataLoaderWeb.Controllers.Oauth2ControllerTest do
  use EaRestaurantDataLoaderWeb.ConnCase
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientFixture
  alias EaRestaurantDataLoader.Test.Fixtures.UserFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientScopeFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppAccessTokenFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppRefreshTokenFixture
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Constants.Oauth2
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.TokenExpiredError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError

  describe "oauth2 controller test" do
    test "Should login using client credentials", %{conn: conn} do
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

      body_params = %{"grant_type" => "CLIENT_CREDENTIALS"}

      conn = put_req_header(conn, "authorization", "Basic cG9zdG1hbjAwMTpwb3N0bWFuc2VjcmV0MDE=")
      conn = post(conn, "/login", body_params)
      {_, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      {_, access_token_decoded} =
        Oauth2Util.get_token_decoded(resp_body_decoded["access_token"], secret_key)

      assert access_token_decoded["clientName"] == app_client.client_name
      assert access_token_decoded["scopes"] == scopes.scope
      assert conn.status == 200
    end

    test "Should login using user credentials", %{conn: conn} do
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

      body_params = %{
        "grant_type" => "PASSWORD",
        "username" => "test-username",
        "password" => "1234"
      }

      conn = put_req_header(conn, "authorization", "Basic cG9zdG1hbjAwMTpwb3N0bWFuc2VjcmV0MDE=")
      conn = post(conn, "/login", body_params)
      {_, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      {_, access_token_decoded} =
        Oauth2Util.get_token_decoded(resp_body_decoded["access_token"], secret_key)

      user_from_token = Map.get(access_token_decoded, "user")
      assert access_token_decoded["clientName"] == app_client.client_name
      assert access_token_decoded["scopes"] == scopes.scope
      assert user_from_token["name"] == user.name
      assert user_from_token["username"] == user.username

      assert conn.status == 200
    end

    test "Should raise InvalidCredentialError when login with wrong credentials", %{conn: conn} do
      body_params = %{"grant_type" => "CLIENT_CREDENTIALS"}
      conn = put_req_header(conn, "authorization", "Basic cG9zdG1hbjpwb3N0bWFuMDE=")

      assert_raise(InvalidCredentialsError, ~r/Invalid Credentials/, fn ->
        post(conn, "/login", body_params)
      end)
    end

    test "Should raise BadRequestError when login with wrong basic auth", %{conn: conn} do
      body_params = %{"grant_type" => "CLIENT_CREDENTIALS"}
      conn = put_req_header(conn, "authorization", "Basic bad-base64")

      assert_raise(BadRequest, ~r/bad request/, fn -> post(conn, "/login", body_params) end)
    end

    test "Should return same access token when refresh an unexpired access token", %{conn: conn} do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ/WRITE", client.id, user)

      access_token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: client.client_name,
          scopes: scopes.scope,
          exp_time: client.refresh_token_expiration_time,
          secret_key: secret_key
        })

      refresh_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: client.refresh_token_expiration_time,
            secret_key: secret_key
          }
        )

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

      body_params = %{
        "access_token" => access_token,
        "refresh_token" => refresh_token,
        "client_id" => "postman001",
        "client_secret" => "postmansecret01"
      }

      conn = put_req_header(conn, "authorization", "Bearer " <> refresh_token)
      conn = post(conn, "/refresh_token", body_params)
      {_, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      assert conn.status == 200
      assert resp_body_decoded["access_token"] == access_token
    end

    test "Should create new access token when refresh expired access token", %{conn: conn} do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ/WRITE", client.id, user)

      expired_access_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: 0,
            secret_key: secret_key
          }
        )

      refresh_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: client.refresh_token_expiration_time,
            secret_key: secret_key
          }
        )

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

      body_params = %{
        "access_token" => expired_access_token,
        "refresh_token" => refresh_token,
        "client_id" => "postman001",
        "client_secret" => "postmansecret01"
      }

      conn = put_req_header(conn, "authorization", "Bearer " <> refresh_token)
      conn = post(conn, "/refresh_token", body_params)
      {_, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      assert conn.status == 200
      assert resp_body_decoded["access_token"] != expired_access_token
    end

    test "Should raise TokenExpiredError when refresh access token with expired refresh token", %{
      conn: conn
    } do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ/WRITE", client.id, user)

      expired_access_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: 0,
            secret_key: secret_key
          }
        )

      refresh_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: 10,
            secret_key: secret_key
          }
        )

      expired_refresh_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: 0,
            secret_key: secret_key
          }
        )

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

      body_params = %{
        "access_token" => expired_access_token,
        "refresh_token" => expired_refresh_token,
        "client_id" => "postman001",
        "client_secret" => "postmansecret01"
      }

      conn = put_req_header(conn, "authorization", "Bearer " <> refresh_token)

      assert_raise(
        TokenExpiredError,
        ~r/Token expired/,
        fn ->
          post(conn, "/refresh_token", body_params)
        end
      )
    end

    test "Should raise Unauthorized route when invalid roles", %{conn: conn} do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, client} =
        AppClientFixture.build_and_insert_app_client(
          "postman",
          "postman001",
          user
        )

      {:ok, scopes} =
        AppClientScopeFixture.build_and_insert_app_client_scope("READ", client.id, user)

      refresh_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: 10,
            secret_key: secret_key
          }
        )

      access_token =
        Oauth2Util.build_token(
          %{grant_type: "CLIENT_CREDENTIALS"},
          %{
            client_name: client.client_name,
            scopes: scopes.scope,
            exp_time: client.access_token_expiration_time,
            secret_key: secret_key
          }
        )

      body_params = %{
        "access_token" => access_token,
        "refresh_token" => refresh_token,
        "client_id" => "postman001",
        "client_secret" => "postmansecret01"
      }

      conn = put_req_header(conn, "authorization", "Bearer " <> refresh_token)

      assert_raise(
        UnauthorizedRouteError,
        ~r/Route unauthorized/,
        fn ->
          post(conn, "/refresh_token", body_params)
        end
      )
    end
  end
end
