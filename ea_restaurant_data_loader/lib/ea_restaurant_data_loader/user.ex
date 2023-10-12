defmodule EaRestaurantDataLoader.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :type, Ecto.Enum, values: [:INTERNAL, :EXTERNAL]
    field :username, :string
    field :password, :string
    field :role, Ecto.Enum, values: [:CHEF, :CLIENT, :CASHIER, :SEEDER, :KITCHEN_SIMULATOR]
    field :last_name, :string
    field :entity_status, :string
    field :created_by, :integer
    field :updated_by, :integer
    field :created_date, :naive_datetime
    field :updated_date, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :last_name, :username, :password, :role, :type, :entity_status, :created_by, :updated_by, :created_date, :updated_date])
    |> validate_required([:name, :last_name, :username, :password, :role, :type, :entity_status, :created_by, :updated_by, :created_date, :updated_date])
  end
end
