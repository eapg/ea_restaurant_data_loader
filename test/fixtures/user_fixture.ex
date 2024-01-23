defmodule EaRestaurantDataLoader.Test.Fixtures.UserFixture do
  alias EaRestaurantDataLoader.Lib.Entities.User
  alias EaRestaurantDataLoader.Repo

  def build_user(name, username),
    do:
      %User{}
      |> User.changeset(%{
        name: name,
        type: :INTERNAL,
        username: username,
        password: "MTIzNA==",
        roles: :CHEF,
        last_name: "test-lastname",
        entity_status: "ACTIVE",
        created_by: 1,
        updated_by: 1,
        created_date: DateTime.utc_now(),
        updated_date: DateTime.utc_now()
      })

  def build_and_insert_user(name, username),
    do:
      build_user(name, username)
      |> Repo.insert()
end
