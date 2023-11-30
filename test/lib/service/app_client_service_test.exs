defmodule EaRestaurantDataLoader.AppClientServiceTest do
  use EaRestaurantDataLoader.RepoCase

  alias EaRestaurantDataLoader.AppClientService
  alias EaRestaurantDataLoader.AppClientFixture
  alias EaRestaurantDataLoader.UserFixture

  describe "app client service test" do
    test "get app client by client id should return expected app client" do
      {:ok, user} = UserFixture.build_and_insert_user("test-user", "test-username")

      {:ok, app_client} =
        AppClientFixture.build_and_insert_app_client(
          "test-client",
          "test-client-id",
          user
        )

      expected_client = AppClientService.get_client_by_client_id("test-client-id")

      assert user.id == expected_client.created_by
      assert user.id == expected_client.updated_by
      assert expected_client.client_name == app_client.client_name
      assert expected_client.client_id == app_client.client_id
    end
  end
end
