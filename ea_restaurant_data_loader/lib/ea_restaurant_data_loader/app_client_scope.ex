defmodule EaRestaurantDataLoader.AppClientScope do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppClient

  schema "app_clients_scopes" do
    field(:scope, :string)
    field(:entity_status, :string)
    field(:created_date, :naive_datetime)
    field(:updated_date, :naive_datetime)
    belongs_to(:created_by, User)
    belongs_to(:updated_by, User)
    belongs_to(:app_client_id, AppClient)

    timestamps()
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
