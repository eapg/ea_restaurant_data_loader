defmodule EaRestaurantDataLoader.AppClientService do
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.AppClient
  import Ecto.Query

  def get_client_by_client_id(client_id),
    do: Repo.get_by(AppClient, client_id: client_id)
end
