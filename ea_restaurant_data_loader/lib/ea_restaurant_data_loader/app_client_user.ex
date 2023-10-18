defmodule EaRestaurantDataLoader.AppClientUser do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppClient

  schema "app_client_users" do
    field(:username, :string)
    field(:entity_status, :string)
    field(:created_date, :naive_datetime)
    field(:updated_date, :naive_datetime)
    belongs_to(:created_by, User)
    belongs_to(:updated_by, User)
    belongs_to(:app_client_id, AppClient)

    timestamps()
  end

  @doc false
  def changeset(app_client_user, attrs) do
    app_client_user
    |> cast(attrs, [
      :app_client_id,
      :username,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
    |> validate_required([
      :app_client_id,
      :username,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
  end
end
