defmodule EaRestaurantDataLoader.Oauth2ServiceTest do
  use EaRestaurantDataLoader.RepoCase
  alias EaRestaurantDataLoader.Oauth2Service
  alias EaRestaurantDataLoader.AppClientFixture
  alias EaRestaurantDataLoader.UserFixture
  alias EaRestaurantDataLoader.AppClientScopeFixture
  alias EaRestaurantDataLoader.Oauth2Util

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
  end
end
