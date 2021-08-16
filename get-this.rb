require 'sinatra'
require "alma_rest_client"
require 'byebug'
require 'active_support/all' 
require 'omniauth'
require 'omniauth_openid_connect'

Time.zone = 'Eastern Time (US & Canada)'

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/options/media_booking"
require_relative "./models/options"
require_relative "./lib/closed_days"

enable :sessions
set :session_secret, ENV['RACK_COOKIE_SECRET'] 
set server: 'thin', connections: []

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: 'https://weblogin.lib.umich.edu',
    discovery: true,
    client_auth_method: 'jwks',
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV['WEBLOGIN_ID'],
      secret: ENV['WEBLOGIN_SECRET'],
      redirect_uri: "#{ENV['GET_THIS_BASE_URL']}/auth/openid_connect/callback"
    }
  }
end
get '/auth/openid_connect/callback' do
  auth = request.env['omniauth.auth']
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  session[:uniqname] = info[:nickname]
  redirect session.delete(:path_before_login) || '/' 
end

# :nocov:
get '/auth/failure' do
  "You are not authorized"
end
# :nocov:

get '/logout' do
  session.clear
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"
end

get '/login' do
  redirect '/auth/openid_connect'
end

before  do
  Time.zone = 'Eastern Time (US & Canada)'
  pass if ['auth', 'session_switcher', 'logout', 'login'].include? request.path_info.split('/')[1]

  if dev_login?
    session[:uniqname] = 'mlibrary.acct.testing1@gmail.com' unless session[:uniqname]
    pass
  end

  session[:path_before_login] = request.path_info

  #authenticated but expired go relogin
  if session[:authenticated] && Time.now.utc > session[:expires_at]
    redirect '/auth/openid_connect'
  end
end

helpers do
  def dev_login?
    ENV['WEBLOGIN_ON'] == "false" && settings.environment == :development
  end
end

# :nocov:
get '/session_switcher' do
  session[:uniqname] = params[:uniqname]
  redirect "/#{params[:barcode]}"
end
# :nocov:

get '/:barcode' do
  barcode = params['barcode'] #need to check that this is valid barcode
  if session[:authenticated] == true
    patron = Patron.for(session[:uniqname])
  else
    patron = Patron::NotInAlma.new
  end
  item = Item.for(barcode)
  options = Options.for(patron: patron, item: item)
  erb :index, locals: {patron: patron, item: item, options: options}
end

get '/' do
  redirect "https://www.lib.umich.edu/find-borrow-request"
end

post '/booking' do
  
end
