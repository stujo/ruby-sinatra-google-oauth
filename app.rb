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

use Rack::Session::Pool, :expire_after => 2592000

require_relative 'helpers/auth.rb'

before do
  pass if request.path_info == auth_callback_path
  pass if request.path_info == auth_logout_path
  auth_refresh_token_if_necessary
end

get '/' do
  if !session[:access_token].nil?
    erb :index
  else
    erb :login
  end
end

get '/logout' do
  auth_sign_out
  redirect '/'
end

get '/auth/callback' do
  auth_process_code params[:code]
  redirect '/'
end

