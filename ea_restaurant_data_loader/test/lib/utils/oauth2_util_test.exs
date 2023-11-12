defmodule EaRestaurantDataLoader.Oauth2UtilTest do
  use ExUnit.Case
  doctest EaRestaurantDataLoader.Oauth2Util
  alias EaRestaurantDataLoader.Oauth2Util

  describe "Oauth2Util Test" do
    test "build client credential token successfully" do
      token = Oauth2Util.build_client_credentials_token("ea_restaurant", "READ", 1, "1234")
      {_, claims} = Oauth2Util.get_token_decoded(token, "1234")
      assert "ea_restaurant" == claims["clientName"]
      assert "READ" == claims["scopes"]
    end

    test " verify expired token" do
      token = Oauth2Util.build_client_credentials_token("ea_restaurant", "READ", -1, "1234")
      {status, message} = Oauth2Util.validate_token(token, "1234")
      assert message == "Invalid token"
      assert status == :error
    end
  end
end
