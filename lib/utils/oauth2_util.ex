defmodule EaRestaurantDataLoader.Oauth2Util do
  alias EaRestaurantDataLoader.Token

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
      {:ok, claims} ->
        {:ok, nil}

      {:error, error_message_list} ->
        [head | _] = error_message_list
        {_, message_description} = head
        {:error, message_description}
    end
  end
end
