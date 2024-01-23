defmodule EaRestaurantDataLoader.Lib.Utils.Oauth2Util do
  alias EaRestaurantDataLoader.Lib.Auth.Token
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidTokenError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError

  @routes_scopes %{"/refresh_token" => "READ/WRITE"}

  defp signer(secret_key) do
    Joken.Signer.create("HS256", secret_key)
  end

  def build_token(%{grant_type: "CLIENT_CREDENTIALS"}, args) do
    extra_claims = %{
      "exp" => DateTime.utc_now() |> DateTime.add(args.exp_time, :second) |> DateTime.to_unix(),
      "clientName" => args.client_name,
      "scopes" => args.scopes
    }

    Token.generate_and_sign!(extra_claims, signer(args.secret_key))
  end

  def build_token(%{grant_type: "PASSWORD"}, args) do
    extra_claims = %{
      "exp" => DateTime.utc_now() |> DateTime.add(args.exp_time, :second) |> DateTime.to_unix(),
      "clientName" => args.client_name,
      "scopes" => args.scopes,
      "user" => %{
        "username" => args.user.username,
        "name" => args.user.name,
        "last_name" => args.user.last_name,
        "roles" => args.user.roles
      }
    }

    Token.generate_and_sign!(extra_claims, signer(args.secret_key))
  end

  def build_token(_args) do
    raise InvalidCredentialsError
  end

  def get_token_decoded(token, secret_key) do
    case Token.verify(token, signer(secret_key)) do
      {:ok, claims} ->
        {:ok, claims}

      _ ->
        raise InvalidTokenError
    end
  end

  def validate_token(token, secret_key) do
    {_, claims} = get_token_decoded(token, secret_key)

    case Token.validate(claims) do
      {:ok, _} ->
        {:ok, nil}

      {:error, error_message_list} ->
        [head | _] = error_message_list
        {_, message_description} = head
        {:error, message_description}
    end
  end

  def get_expiration_time_in_seconds(token, secret_key) do
    {_, token_decoded} = get_token_decoded(token, secret_key)
    %{"exp" => expiration_time} = token_decoded
    unix_datetime = DateTime.utc_now() |> DateTime.to_unix()
    expiration_time - unix_datetime
  end

  def decrypt_client_credentials(encrypted_client_credentials) do
    Base.decode64(encrypted_client_credentials, case: :mixed)
  end

  def extract_client_credentials_from_basic_auth(basic_auth) do
    [_, encrypted_client_credentials] = String.split(basic_auth, " ")
    {:ok, decoded_client_credentials} = decrypt_client_credentials(encrypted_client_credentials)
    String.split(decoded_client_credentials, ":")
  end

  def validate_route_protection(token, secret_key, conn) do
    {:ok, token_decoded} =
      case validate_token(token, secret_key) do
        {:ok, _} ->
          get_token_decoded(token, secret_key)

        {:error, _} ->
          raise UnauthorizedRouteError
      end

    case token_decoded["scopes"] == get_route_scopes(conn.request_path) do
      true ->
        conn

      false ->
        raise UnauthorizedRouteError
    end
  end

  def get_route_scopes(route),
    do:
      @routes_scopes
      |> Map.get(route)
end
