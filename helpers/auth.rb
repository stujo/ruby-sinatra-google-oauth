require 'securerandom'

helpers do

  def auth_authenticated?
    false
  end  

  def auth_random_string
    SecureRandom.hex
  end

end