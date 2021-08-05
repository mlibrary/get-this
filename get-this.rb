require 'sinatra'
require "alma_rest_client"
require 'byebug'
get '/' do
  erb :index
end
