defmodule EaRestaurantDataLoader.AppClientScope do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppClient

  schema "app_clients_scopes" do
    field(:scope, :string)
    field(:app_client_id, :integer)
    field(:entity_status, :string)
    field(:created_date, :naive_datetime)
    field(:updated_date, :naive_datetime)
    field(:created_by, :integer)
    field(:updated_by, :integer)
    belongs_to(:created_by_user, User, source: :created_by, define_field: false)
    belongs_to(:updated_by_user, User, source: :updated_by, define_field: false)
    belongs_to(:app_client, AppClient, source: :app_client_id, define_field: false)
  end

  @doc false
  def changeset(app_client_scope, attrs) do
    app_client_scope
    |> cast(attrs, [
      :app_client_id,
      :scope,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
    |> validate_required([
      :app_client_id,
      :scope,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
  end
end
