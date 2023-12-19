defmodule EaRestaurantDataLoader.Lib.Utils.ApplicationUtil do
  alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.Base64

  @password_encoder_struct_map %{base64: %Base64{}, bcrpyt: nil}

  def build_password_encoder_struct(password_encoding_type, password, encoded_password) do
     @password_encoder_struct_map
     |> Map.get(password_encoding_type)
     |> Map.put(:password, password)
     |> Map.put(:encoded_password, encoded_password)

  end

  def build_password_type_from_env(password, enconded_password) do
    build_password_encoder_struct(
      Application.get_env(:ea_restaurant_data_loader, :password_encoding_type),
      password,
      enconded_password
    )
  end
end
