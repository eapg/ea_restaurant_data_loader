defmodule EaRestaurantDataLoader.Lib.Constants.Oauth2 do
  @values ["CLIENT_CREDENTIALS"]

  def get_values, do: @values

  def client_credentials, do: get_values() |> Enum.at(0)
end
