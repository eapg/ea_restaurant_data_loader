defmodule EaRestaurantDataLoader.Test.Support.MongoHelper do
  def cleanup_mongo_collections do
    {:ok, conn} =
      Mongo.start_link(
        url:
          Application.get_env(:ea_restaurant_data_loader, EaRestaurantDataLoader.MongoRepo)[:url]
      )

    collections = ["products"]
    Enum.each(collections, fn collection -> Mongo.drop_collection(conn, collection) end)
  end
end
