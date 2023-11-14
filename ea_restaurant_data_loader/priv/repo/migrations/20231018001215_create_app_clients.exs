defmodule EaRestaurantDataLoader.Repo.Migrations.CreateAppClients do
  use Ecto.Migration

  def change do
    create table(:app_clients) do
      add :client_name, :string
      add :client_id, :string
      add :client_secret, :string
      add :access_token_expiration_time, :integer
      add :refresh_token_expiration_time, :integer
      add :entity_status, :string
      add :created_by, references(:users)
      add :updated_by, references(:users)
      add :created_date, :naive_datetime
      add :updated_date, :naive_datetime
    end
  end
end
