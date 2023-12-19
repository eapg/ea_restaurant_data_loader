alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.PasswordEncoder
alias EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.Base64

defimpl PasswordEncoder, for: Base64 do
  def validate_password(pass_data) do
    decoded_pass = Base.decode64(pass_data.encoded_password, case: :mixed)
    {:ok, pass_data.password} == decoded_pass
  end

  def encode_password(pass_data) do
    Base.encode64(pass_data.password)
  end
  
end  

