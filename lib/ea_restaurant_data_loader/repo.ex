defmodule EaRestaurantDataLoader.Repo do
  use Ecto.Repo,
    otp_app: :ea_restaurant_data_loader,
    adapter: Ecto.Adapters.Postgres
end
