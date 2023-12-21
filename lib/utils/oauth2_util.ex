defmodule EaRestaurantDataLoader.Lib.Utils.Oauth2Util do
  alias EaRestaurantDataLoader.Lib.Auth.Token

  defp signer(secret_key) do
    Joken.Signer.create("HS256", secret_key)
  end

  def build_client_credentials_token(client_name, scopes, exp_time, secret_key) do
    extra_claims = %{
      "exp" => DateTime.utc_now() |> DateTime.add(exp_time, :second) |> DateTime.to_unix(),
      "clientName" => client_name,
      "scopes" => scopes
    }

    Token.generate_and_sign!(extra_claims, signer(secret_key))
  end

  def get_token_decoded(token, secret_key) do
    Token.verify(token, signer(secret_key))
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
end
