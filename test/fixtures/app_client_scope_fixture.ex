defmodule EaRestaurantDataLoader.AppClientScopeFixture do
  alias EaRestaurantDataLoader.AppClientScope
  alias EaRestaurantDataLoader.Repo

  def build_app_client_scope(scopes, app_client_id, user),
    do:
      %AppClientScope{}
      |> AppClientScope.changeset(%{
        scope: scopes,
        app_client_id: app_client_id,
        entity_status: "ACTIVE",
        created_by: user.id,
        updated_by: user.id,
        created_date: DateTime.utc_now(),
        updated_date: DateTime.utc_now()
      })

  def build_and_insert_app_client_scope(scopes, app_client_id, user),
    do:
      build_app_client_scope(scopes, app_client_id, user)
      |> Repo.insert()
end
