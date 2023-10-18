defmodule EaRestaurantDataLoader.Repo.Migrations.CreateAppClientsScopes do
  use Ecto.Migration

  def change do
    create table(:app_clients_scopes) do
      add :app_client_id, references(:app_clients)
      add :scope, :string
      add :entity_status, :string
      add :created_by, references(:users)
      add :updated_by, references(:users)
      add :created_date, :naive_datetime
      add :updated_date, :naive_datetime

      timestamps()
    end

  end
end
