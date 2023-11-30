defmodule EaRestaurantDataLoader.Repo.Migrations.CreateAppClientUsers do
  use Ecto.Migration

  def change do
    create table(:app_client_users) do
      add :app_client_id, references(:app_clients)
      add :username, :string
      add :entity_status, :string
      add :created_by, references(:users)
      add :updated_by, references(:users)
      add :created_date, :naive_datetime
      add :updated_date, :naive_datetime
    end
  end
end
