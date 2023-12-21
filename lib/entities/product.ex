defmodule EaRestaurantDataLoader.Lib.Entities.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.Lib.Entities.User

  schema "products" do
    field :name, :string
    field :description, :string
    field :entity_status, :string
    field :created_date, :naive_datetime
    field :updated_date, :naive_datetime
    field(:created_by, :integer)
    field(:updated_by, :integer)
    belongs_to(:created_by_user, User, source: :created_by, define_field: false)
    belongs_to(:updated_by_user, User, source: :updated_by, define_field: false)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
    |> validate_required([
      :name,
      :description,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
  end
end
