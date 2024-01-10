defmodule EaRestaurantDataLoader.Lib.Constants.Oauth2 do
  @values ["CLIENT_CREDENTIALS", "PASSWORD"]

  def get_values, do: @values

  def client_credentials, do: get_values() |> Enum.at(0)

  def password, do: get_values() |> Enum.at(1)
end
