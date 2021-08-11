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


before  do
  session[:uniqname] = 'mrio' unless session[:uniqname]
  Time.zone = 'Eastern Time (US & Canada)'
end

get '/:barcode' do
  barcode = params['barcode'] #need to check that this is valid barcode
  patron = Patron.for(session[:uniqname])
  item = Item.for(barcode)
  options = Options.for(patron: patron, item: item)
  erb :index, locals: {patron: patron, item: item, options: options}
end
