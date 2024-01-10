defmodule EaRestaurantDataLoader.Lib.Entities.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :type, Ecto.Enum, values: [:INTERNAL, :EXTERNAL]
    field :username, :string
    field :password, :string
    field :roles, Ecto.Enum, values: [:CHEF, :CLIENT, :CASHIER, :SEEDER, :KITCHEN_SIMULATOR, :ADMINISTRATOR]
    field :last_name, :string
    field :entity_status, :string
    field(:created_by, :integer)
    field(:updated_by, :integer)
    belongs_to(:created_by_user, User, source: :created_by, define_field: false)
    belongs_to(:updated_by_user, User, source: :updated_by, define_field: false)
    field :created_date, :naive_datetime
    field :updated_date, :naive_datetime
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :last_name,
      :username,
      :password,
      :roles,
      :type,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
    |> validate_required([
      :name,
      :last_name,
      :username,
      :password,
      :roles,
      :type,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
  end
end
