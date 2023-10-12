defmodule EaRestaurantDataLoader.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :last_name, :string
      add :username, :string
      add :password, :string
      add :role, :string
      add :type, :string
      add :entity_status, :string
      add :created_by, :integer
      add :updated_by, :integer
      add :created_date, :naive_datetime
      add :updated_date, :naive_datetime

      timestamps()
    end

  end
end
