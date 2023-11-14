defmodule EaRestaurantDataLoader.AppRefreshToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppClient

  schema "app_refresh_tokens" do
    field(:token, :string)
    field(:grant_type, :string)
    belongs_to(:app_client_id, AppClient)
  end

  @doc false
  def changeset(app_refresh_token, attrs) do
    app_refresh_token
    |> cast(attrs, [:token, :grant_type, :app_client_id])
    |> validate_required([:token, :grant_type, :app_client_id])
  end
end
