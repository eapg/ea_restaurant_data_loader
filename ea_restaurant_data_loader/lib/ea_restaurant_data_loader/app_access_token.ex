defmodule EaRestaurantDataLoader.AppAccessToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.AppRefreshToken

  schema "app_access_tokens" do
    field(:token, :string)
    belongs_to(:refresh_token_id, AppRefreshToken)

    timestamps()
  end

  @doc false
  def changeset(app_access_token, attrs) do
    app_access_token
    |> cast(attrs, [:refresh_token_id, :token])
    |> validate_required([:refresh_token_id, :token])
  end
end
