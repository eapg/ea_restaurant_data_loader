defmodule EaRestaurantDataLoader.Test.EaRestaurantDataLoaderWeb.Controllers.Oauth2ControllerTest do
  use EaRestaurantDataLoaderWeb.ConnCase
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientFixture
  alias EaRestaurantDataLoader.Test.Fixtures.UserFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientScopeFixture
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest

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

      conn = put_req_header(conn, "authorization", "Basic cG9zdG1hbjAwMTpwb3N0bWFuc2VjcmV0MDE=")
      conn = post(conn, "/login")
      {_, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      {_, access_token_decoded} =
        Oauth2Util.get_token_decoded(resp_body_decoded["access_token"], secret_key)

      assert access_token_decoded["clientName"] == app_client.client_name
      assert access_token_decoded["scopes"] == scopes.scope
      assert conn.status == 200
    end

    test "Should raise InvalidCredentialError when login with wrong credentials", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Basic cG9zdG1hbjpwb3N0bWFuMDE=")

      assert_raise(InvalidCredentialsError, ~r/Invalid Credentials/, fn ->
        post(conn, "/login")
      end)
    end

    test "Should raise BadRequestError when login with wrong basic auth", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "Basic bad-base64")

      assert_raise(BadRequest, ~r/bad request/, fn -> post(conn, "/login") end)
    end
  end
end
