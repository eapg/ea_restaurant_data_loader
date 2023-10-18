defmodule EaRestaurantDataLoader.Repo.Migrations.CreateAppRefreshTokens do
  use Ecto.Migration

  def change do
    create table(:app_refresh_tokens) do
      add :token, :string
      add :grant_type, :string
      add :app_client_id, references(:app_clients)

      timestamps()
    end

  end
end
