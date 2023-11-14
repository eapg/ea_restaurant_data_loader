defmodule EaRestaurantDataLoader.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :entity_status, :string
      add :created_by, references(:users)
      add :updated_by, references(:users)
      add :created_date, :naive_datetime
      add :updated_date, :naive_datetime
    end
  end
end
