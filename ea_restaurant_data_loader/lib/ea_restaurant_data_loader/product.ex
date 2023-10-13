defmodule EaRestaurantDataLoader.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.User

  schema "products" do
    field :name, :string
    field :description, :string
    field :entity_status, :string
    field :created_date, :naive_datetime
    field :updated_date, :naive_datetime
    belongs_to :created_by, User
    belongs_to :updated_by, User

    timestamps()
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
