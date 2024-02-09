defmodule EaRestaurantDataLoader.MongoRepo do
  use Mongo.Repo,
    otp_app: :ea_restaurant_data_loader,
    topology: :mongo
end
