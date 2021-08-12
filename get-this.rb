require 'sinatra'
require "alma_rest_client"
require 'byebug'
require 'active_support/all' 

Time.zone = 'Eastern Time (US & Canada)'

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/options/media_booking"
require_relative "./models/options"
require_relative "./lib/closed_days"

enable :sessions
set server: 'thin', connections: []

before  do
  session[:uniqname] = 'mlibrary.acct.testing1@gmail.com' unless session[:uniqname]
  Time.zone = 'Eastern Time (US & Canada)'
end

# :nocov:
get '/session_switcher' do
  session[:uniqname] = params[:uniqname]
  redirect "/#{params[:barcode]}"
end
# :nocov:

get '/:barcode' do
  barcode = params['barcode'] #need to check that this is valid barcode
  patron = Patron.for(session[:uniqname])
  item = Item.for(barcode)
  options = Options.for(patron: patron, item: item)
  erb :index, locals: {patron: patron, item: item, options: options}
end

post '/booking' do
  
end
