defmodule EaRestaurantDataLoader.Lib.Service.ProductService do
  alias EaRestaurantDataLoader.Lib.Documents.Product
  alias EaRestaurantDataLoader.MongoRepo

  def get_products, do: MongoRepo.all(Product)

  def insert_products(products), do: MongoRepo.insert_all(Product, products)
end
