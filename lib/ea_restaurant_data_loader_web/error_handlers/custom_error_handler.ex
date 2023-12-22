defmodule EaRestaurantDataLoaderWeb.ErrorHandlers.CustomErrorHandler do
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest

  def handle(reason) do

    case reason do
      %InvalidCredentialsError{} ->
        {:unauthorized, reason.message}
      %BadRequest{} ->
        {:bad_request, reason.message}

        _ ->
        {:internal_server_error, "Internal Server Error"}
    end
  end
end
