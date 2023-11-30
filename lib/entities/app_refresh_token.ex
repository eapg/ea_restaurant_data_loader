defmodule EaRestaurantDataLoader.AppRefreshToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppClient

  schema "app_refresh_tokens" do
    field(:token, :string)
    field(:grant_type, :string)
    field(:app_client_id, :integer)
    belongs_to(:app_client, AppClient, source: "app_client_id", define_field: false)
  end

  @doc false
  def changeset(app_refresh_token, attrs) do
    app_refresh_token
    |> cast(attrs, [:token, :grant_type, :app_client_id])
    |> validate_required([:token, :grant_type, :app_client_id])
  end
end
