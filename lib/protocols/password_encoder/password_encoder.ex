defprotocol EaRestaurantDataLoader.Lib.Protocols.PasswordEncoder.PasswordEncoder do
  def validate_password(pass_data)
  def encode_password(pass_data)
end
