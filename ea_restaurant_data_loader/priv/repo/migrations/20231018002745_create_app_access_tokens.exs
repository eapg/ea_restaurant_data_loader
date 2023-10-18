defmodule EaRestaurantDataLoader.Repo.Migrations.CreateAppAccessTokens do
  use Ecto.Migration

  def change do
    create table(:app_access_tokens) do
      add :refresh_token_id, references(:app_refresh_tokens)
      add :token, :string

      timestamps()
    end

  end
end
