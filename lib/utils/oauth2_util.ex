defmodule EaRestaurantDataLoader.Lib.Utils.Oauth2Util do
  alias EaRestaurantDataLoader.Lib.Auth.Token
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidTokenError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.UnauthorizedRouteError
  alias EaRestaurantDataLoader.Lib.ErrorHandlers.InvalidCredentialsError
  alias Structs.SecuredHttpRequestUrlPermissions

  @routes_roles_and_scopes %{
    "/refresh_token" => %SecuredHttpRequestUrlPermissions{scopes: ["READ", "WRITE"]}
  }

  defp signer(secret_key) do
    Joken.Signer.create("HS256", secret_key)
  end

  def build_token(%{grant_type: "CLIENT_CREDENTIALS"}, args) do
    extra_claims = %{
      "exp" => DateTime.utc_now() |> DateTime.add(args.exp_time, :second) |> DateTime.to_unix(),
      "clientName" => args.client_name,
      "scopes" => String.split(args.scopes, ",")
    }

    Token.generate_and_sign!(extra_claims, signer(args.secret_key))
  end

  def build_token(%{grant_type: "PASSWORD"}, args) do
    extra_claims = %{
      "exp" => DateTime.utc_now() |> DateTime.add(args.exp_time, :second) |> DateTime.to_unix(),
      "clientName" => args.client_name,
      "scopes" => String.split(args.scopes, ","),
      "user" => %{
        "username" => args.user.username,
        "name" => args.user.name,
        "last_name" => args.user.last_name,
        "roles" => [args.user.roles]
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

  def validate_roles_and_scopes(token, secret_key, conn) do
    {:ok, token_decoded} =
      case validate_token(token, secret_key) do
        {:ok, _} ->
          get_token_decoded(token, secret_key)

        {:error, _} ->
          raise UnauthorizedRouteError
      end

    access_token_roles = Map.get(token_decoded, "roles")
    access_token_scopes = Map.get(token_decoded, "scopes")
    route_url_path = conn.request_path
    route_permissions = Map.get(@routes_roles_and_scopes, route_url_path)

    {scopes_status, scope_status_reason} =
      validate_scopes(%{
        access_token_scopes: access_token_scopes,
        route_permissions_scopes: route_permissions.scopes
      })

    {role_status, role_status_reason} =
      validate_roles(%{
        access_token_roles: access_token_roles,
        route_permissions_roles: route_permissions.roles
      })

    {{scopes_status, scope_status_reason}, {role_status, role_status_reason}}
  end

  def validate_scopes(%{access_token_scopes: nil, route_permissions_scopes: _}),
    do: {:error, :unauthorized_route}

  def validate_scopes(%{
        access_token_scopes: access_token_scopes,
        route_permissions_scopes: route_permissions_scopes
      }) do
    validated_scopes =
      Enum.any?(access_token_scopes, fn scope -> scope in route_permissions_scopes end)

    case validated_scopes do
      true ->
        {:ok, :access_granted}

      false ->
        {:error, :unauthorized_route}
    end
  end

  def validate_roles(%{access_token_roles: _, route_permissions_roles: nil}),
    do: {:ok, :access_granted}

  def validate_roles(%{access_token_roles: nil, route_permissions_roles: _}),
    do: {:error, :unauthorized_route}

  def validate_roles(%{
        access_token_roles: access_token_roles,
        route_permissions_roles: route_permission_roles
      }) do
    validated_roles = Enum.any?(access_token_roles, fn role -> role in route_permission_roles end)

    case validated_roles do
      true ->
        {:ok, :access_granted}

      false ->
        {:error, :unauthorized_route}
    end
  end
end
