require 'securerandom'

helpers do

  def auth_authenticated?
    !!session[:auth]
  end

  def auth_logout
    session.delete :auth
  end

  def auth_current_user
<<-HTML
<h1>#{session[:auth][:name]}</h1>
<img src="#{session[:auth][:avatar]}">
HTML
  end

  def auth_random_string
    SecureRandom.hex
  end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
    auth = settings.api_client.authorization.dup
    auth.redirect_uri = to('/oauth2callback')
    auth.update_token!(session)
    auth
    )
  end
end