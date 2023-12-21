defmodule EaRestaurantDataLoader.Lib.Services.AppClientService do
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.Lib.Entities.AppClient

  def get_client_by_client_id(client_id),
    do: Repo.get_by(AppClient, client_id: client_id)
end
