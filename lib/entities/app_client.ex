defmodule EaRestaurantDataLoader.Lib.Entities.AppClient do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.Lib.Entities.User
  alias EaRestaurantDataLoader.Lib.Entities.AppClientScope

  schema "app_clients" do
    field(:client_name, :string)
    field(:client_id, :string)
    field(:client_secret, :string)
    field(:access_token_expiration_time, :integer)
    field(:refresh_token_expiration_time, :integer)
    field(:entity_status, :string)
    field(:created_date, :naive_datetime)
    field(:updated_date, :naive_datetime)
    field(:created_by, :integer)
    field(:updated_by, :integer)
    belongs_to(:created_by_user, User, source: :created_by, define_field: false)
    belongs_to(:updated_by_user, User, source: :updated_by, define_field: false)
    has_many :scopes, AppClientScope
  end

  @doc false
  def changeset(app_client, attrs) do
    app_client
    |> cast(attrs, [
      :client_name,
      :client_id,
      :client_secret,
      :access_token_expiration_time,
      :refresh_token_expiration_time,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
    |> validate_required([
      :client_name,
      :client_id,
      :client_secret,
      :access_token_expiration_time,
      :refresh_token_expiration_time,
      :entity_status,
      :created_by,
      :updated_by,
      :created_date,
      :updated_date
    ])
  end
end
