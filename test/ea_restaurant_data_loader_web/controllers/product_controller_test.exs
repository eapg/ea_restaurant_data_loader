defmodule EaRestaurantDataLoader.Test.EaRestaurantDataLoaderWeb.Controllers.ProductControllerTest do
  use EaRestaurantDataLoaderWeb.ConnCase
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientFixture
  alias EaRestaurantDataLoader.Test.Fixtures.UserFixture
  alias EaRestaurantDataLoader.Test.Fixtures.AppClientScopeFixture
  alias EaRestaurantDataLoader.Test.Fixtures.ProductDocumentFixture
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Utils.ApplicationUtil
  alias EaRestaurantDataLoader.Test.Support.MongoHelper
  alias EaRestaurantDataLoader.Lib.Constants.HttpStatus

  setup do
    MongoHelper.cleanup_mongo_collections()
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
      Oauth2Util.build_token(%{grant_type: "PASSWORD"}, %{
        client_name: client.client_name,
        scopes: scopes.scope,
        exp_time: client.refresh_token_expiration_time,
        secret_key: secret_key,
        user: user
      })

    {:ok, access_token: access_token}
  end

  describe "product controller test" do
    test " should return a list of products", %{conn: conn, access_token: access_token} do
      product_1 = ProductDocumentFixture.build_product("pizza")
      product_2 = ProductDocumentFixture.build_product("tacos")
      products_to_insert = [product_1, product_2]

      {:ok, _} = Mongo.insert_many(:mongo, "products", products_to_insert)

      conn = put_req_header(conn, "authorization", "Bearer " <> access_token)
      conn = get(conn, "/products")

      {:ok, resp_body_decoded} = ApplicationUtil.decode_json(conn.resp_body)

      assert length(products_to_insert) == length(resp_body_decoded)
    end

    test "insert products should return the inserted products id", %{
      conn: conn,
      access_token: access_token
    } do
      product_1 = ProductDocumentFixture.build_product("pizza")
      product_2 = ProductDocumentFixture.build_product("tacos")
      products_to_insert = [product_1, product_2]
      body_params = %{"products" => products_to_insert}

      conn = put_req_header(conn, "authorization", "Bearer " <> access_token)
      conn = post(conn, "/products/import", body_params)

      assert HttpStatus.ok() == conn.resp_body
    end
  end
end
