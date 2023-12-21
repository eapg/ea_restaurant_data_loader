defmodule EaRestaurantDataLoader.Test.Fixtures.AppClientFixture do
  alias EaRestaurantDataLoader.Lib.Entities.AppClient
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.Lib.Entities.User

  def build_app_client(client_name, client_id, user = %User{}),
    do:
      %AppClient{}
      |> AppClient.changeset(%{
        client_name: client_name,
        client_id: client_id,
        client_secret: "cG9zdG1hbnNlY3JldDAx",
        access_token_expiration_time: 10,
        refresh_token_expiration_time: 100,
        entity_status: "ACTIVE",
        created_by: user.id,
        updated_by: user.id,
        created_date: DateTime.utc_now(),
        updated_date: DateTime.utc_now()
      })

  def build_and_insert_app_client(client_name, client_id, user),
    do:
      build_app_client(client_name, client_id, user)
      |> Repo.insert()
end
