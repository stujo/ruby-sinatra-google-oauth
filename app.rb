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

get '/' do
  erb :index
end  