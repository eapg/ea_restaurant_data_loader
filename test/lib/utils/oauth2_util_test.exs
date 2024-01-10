defmodule EaRestaurantDataLoader.Test.Lib.Utils.Oauth2UtilTest do
  use ExUnit.Case
  doctest EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.Utils.Oauth2Util
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidTokenError

  describe "Oauth2Util Test" do
    test "build client credential token successfully" do
      token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: "ea_restaurant",
          scopes: "READ",
          exp_time: 1,
          secret_key: "1234"
        })

      {_, claims} = Oauth2Util.get_token_decoded(token, "1234")
      assert "ea_restaurant" == claims["clientName"]
      assert "READ" == claims["scopes"]
    end

    test " verify expired token" do
      token =
        Oauth2Util.build_token(%{grant_type: "CLIENT_CREDENTIALS"}, %{
          client_name: "ea_restaurant",
          scopes: "READ",
          exp_time: -1,
          secret_key: "1234"
        })

      {status, message} = Oauth2Util.validate_token(token, "1234")
      assert message == "Invalid token"
      assert status == :error
    end

    test " verify invalid token" do
      secret_key = Application.get_env(:ea_restaurant_data_loader, :secret_key)
      invalid_token = "this-is-not-a-token"

      assert_raise(
        InvalidTokenError,
        ~r/Invalid Token/,
        fn ->
          Oauth2Util.validate_token(invalid_token, secret_key)
        end
      )
    end
  end
end
