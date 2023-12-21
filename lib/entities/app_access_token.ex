defmodule EaRestaurantDataLoader.Lib.Entities.AppAccessToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias EaRestaurantDataLoader.Lib.Entities.AppRefreshToken

  schema "app_access_tokens" do
    field(:token, :string)
    field(:refresh_token_id, :integer)

    belongs_to(:app_refresh_token, AppRefreshToken,
      source: :refresh_token_id,
      define_field: false
    )
  end

  @doc false
  def changeset(app_access_token, attrs) do
    app_access_token
    |> cast(attrs, [:refresh_token_id, :token])
    |> validate_required([:refresh_token_id, :token])
  end
end
