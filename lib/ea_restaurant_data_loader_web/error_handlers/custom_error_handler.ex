defmodule EaRestaurantDataLoaderWeb.ErrorHandlers.CustomErrorHandler do
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.BadRequest
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.TokenExpiredError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidTokenError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError

  def handle(reason) do
    case reason do
      %InvalidCredentialsError{} ->
        {:unauthorized, reason.message}

      %BadRequest{} ->
        {:bad_request, reason.message}

      %TokenExpiredError{} ->
        {:unauthorized, reason.message}

      %InvalidTokenError{} ->
        {:unauthorized, reason.message}

      %UnauthorizedRouteError{} ->
        {:unauthorized, reason.message}

      _ ->
        {:internal_server_error, "Internal Server Error"}
    end
  end
end
