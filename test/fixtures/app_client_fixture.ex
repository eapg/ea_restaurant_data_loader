defmodule EaRestaurantDataLoader.AppClientFixture do
  alias EaRestaurantDataLoader.AppClient
  alias EaRestaurantDataLoader.Repo
  alias EaRestaurantDataLoader.User

  def build_app_client(client_name, client_id, user = %User{}),
    do:
      %AppClient{}
      |> AppClient.changeset(%{
        client_name: client_name,
        client_id: client_id,
        client_secret: "$2a$12$rb1quyHV8c.R4iEE5PlRme/lFZrn3uO2ri1stG7EM1EPa8ZRk2ptC",
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
