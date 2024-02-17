defmodule EaRestaurantDataLoader.Test.Lib.Service.ProductServiceTest do
  use ExUnit.Case

  alias EaRestaurantDataLoader.Lib.Service.ProductService
  alias EaRestaurantDataLoader.Test.Fixtures.ProductDocumentFixture
  alias EaRestaurantDataLoader.Test.Support.MongoHelper

  setup do
    MongoHelper.cleanup_mongo_collections()
    product_1 = ProductDocumentFixture.build_product("pizza")
    product_2 = ProductDocumentFixture.build_product("tacos")

    {:ok, product_1: product_1, product_2: product_2}
  end

  describe "product service test" do
    test "get all products from collection successfully", %{
      product_1: product_1,
      product_2: product_2
    } do
      products_to_insert = [product_1, product_2]
      {:ok, _} = Mongo.insert_many(:mongo, "products", products_to_insert)

      products = ProductService.get_products()
      assert length(products) == length(products_to_insert)
    end

    test "insert many products successfully", %{product_1: product_1, product_2: product_2} do
      assert {:ok, 2, _ids} = ProductService.insert_products([product_1, product_2])
    end
  end
end
