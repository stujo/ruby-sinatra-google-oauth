require 'oauth2'


GOOGLE_API_SCOPES = ['https://www.googleapis.com/auth/plus.me'].join(' ')

helpers do
  def auth_client
    @auth_client ||= OAuth2::Client.new(ENV['GOOGLE_API_CLIENT'], ENV['GOOGLE_API_SECRET'], {
                                                                    :site => 'https://accounts.google.com',
                                                                    :authorize_url => "/o/oauth2/auth",
                                                                    :token_url => "/o/oauth2/token"
                                                                })
  end

  def auth_token_wrapper
    @auth_token_wrapper ||= OAuth2::AccessToken.new(auth_client,
                                                    session[:access_token],
                                                    {
                                                        :refresh_token => session[:refresh_token],
                                                        :header_format => 'OAuth %s'
                                                    }
    )
  end

  def auth_refresh_token_if_necessary
    oatoken = auth_token_wrapper
    if oatoken.refresh_token
      oatoken.refresh!
      session[:access_token] = oatoken.token
      session[:refresh_token] = oatoken.refresh_token
    end
  end

  def auth_process_code(code)
    new_token = auth_client.auth_code.get_token(code, :redirect_uri => auth_callback_full_url)
    auth_set_current_user(new_token.token, new_token.refresh_token)
  end


  def auth_set_current_user token, refresh_token
    session[:access_token] = token
    session[:refresh_token] = refresh_token
    session[:user_info] = auth_token_wrapper.get("https://www.googleapis.com/oauth2/v3/userinfo").parsed
  end

  def auth_user_info
    session[:user_info]
  end

  def auth_callback_path
    '/auth/callback'
  end

  def auth_logout_path
    '/logout'
  end

  def auth_callback_full_url
    "#{request.base_url}#{auth_callback_path}"
  end

  def auth_authorize_link
    auth_client.auth_code.authorize_url({
                                            :redirect_uri => auth_callback_full_url,
                                            :scope => GOOGLE_API_SCOPES,
                                            :access_type => "offline"
                                        })
  end

  def auth_sign_out
    session.delete :access_token
    session.delete :refresh_token
    session.delete :user_info
  end
end