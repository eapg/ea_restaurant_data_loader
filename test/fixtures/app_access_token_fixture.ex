defmodule EaRestaurantDataLoader.Test.Fixtures.AppAccessTokenFixture do
  alias EaRestaurantDataLoader.Lib.Entities.AppAccessToken
  alias EaRestaurantDataLoader.Repo

  def build_app_access_token(access_token, app_refresh_token_id),
    do:
      %AppAccessToken{}
      |> AppAccessToken.changeset(%{
        token: access_token,
        refresh_token_id: app_refresh_token_id
      })

  def build_and_insert_app_access_token(access_token, app_refresh_token_id),
    do:
      build_app_access_token(access_token, app_refresh_token_id)
      |> Repo.insert()
end
