begin
  require 'dotenv'
  Dotenv.load
rescue
end

require 'sinatra'
require 'better_errors'
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

enable :sessions

require_relative 'helpers/auth.rb'
require 'google/api_client'
require 'google/api_client/client_secrets'


puts ENV['GOOGLE_CLIENT_ID']

configure do
  client = Google::APIClient.new(
      :application_name => 'Ruby Calendar sample',
      :application_version => '1.0.0')

  client_secrets = Google::APIClient::ClientSecrets.new(
      {
          'web' => {
              :client_id => ENV['GOOGLE_CLIENT_ID'],
              :client_secret => ENV['GOOGLE_CLIENT_SECRET']
          }
      }
  )
  client.authorization = client_secrets.to_authorization
  client.authorization.scope = 'profile https://www.googleapis.com/auth/calendar'

  calendar = client.discovered_api('calendar', 'v3')
  plus = client.discovered_api('plus', 'v1')
  oauth2 = client.discovered_api('oauth2', 'v2')


  # set :logger, logger
  set :api_client, client
  set :calendar_api, calendar
  set :plus_api, plus
  set :oauth2_api, oauth2
end


get '/' do
  erb :index
end

get '/login' do
  redirect user_credentials.authorization_uri.to_s, 303
end

get '/logout' do
  auth_logout
  redirect '/'
end


get '/oauth2callback' do
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!
  auth = {}
  auth[:access_token] = user_credentials.access_token
  auth[:refresh_token] = user_credentials.refresh_token
  auth[:expires_at] = Time.now + user_credentials.expires_in
  auth[:issued_at] = user_credentials.issued_at

  result = settings.api_client.execute(:api_method => settings.oauth2_api.userinfo.get,
                                       :authorization => user_credentials)

  userinfo = result.data if result.status == 200

  auth[:name] = userinfo.name
  auth[:avatar] = userinfo.picture

  session[:auth] = auth

  redirect to('/')
end

