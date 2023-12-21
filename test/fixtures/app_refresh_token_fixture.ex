defmodule EaRestaurantDataLoader.Test.Fixtures.AppRefreshTokenFixture do
  alias EaRestaurantDataLoader.Lib.Entities.AppRefreshToken
  alias EaRestaurantDataLoader.Repo

  def build_app_refresh_token(refresh_token, grant_type, app_client_id),
    do:
      %AppRefreshToken{}
      |> AppRefreshToken.changeset(%{
        token: refresh_token,
        grant_type: grant_type,
        app_client_id: app_client_id
      })

  def build_and_insert_app_refresh_token(refresh_token, grant_type, app_client_id),
    do:
      build_app_refresh_token(refresh_token, grant_type, app_client_id)
      |> Repo.insert()
end
