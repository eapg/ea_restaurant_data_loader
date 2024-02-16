defmodule EaRestaurantDataLoaderWeb.Controllers.ProductController do
  use EaRestaurantDataLoaderWeb, :controller
  alias EaRestaurantDataLoader.Lib.Service.ProductService
  alias EaRestaurantDataLoader.Lib.Util.MongoDbUtil
  alias EaRestaurantDataLoader.Lib.Constants.HttpStatus

  def get_products(conn, _params) do
    products = ProductService.get_products()

    updated_products =
      Enum.map(products, fn product -> MongoDbUtil.update_document_id_to_string(product) end)

    send_resp(conn, :ok, Poison.encode!(updated_products))
  end

  def import_products(conn, _params) do
    %{"products" => products} = conn.body_params
    {:ok, _products_count, _products_bson_object_id} = ProductService.insert_products(products)

    send_resp(conn, :ok, HttpStatus.ok())
  end
end
