require 'sinatra'
require "alma_rest_client"
require 'byebug'

require_relative "./models/patron"
require_relative "./models/item"
require_relative "./models/options"

before  do
  session[:uniqname] == 'mlibrary.acct.testing1@gmail.com' unless session[:uniqname]
end

get '/:barcode' do
  barcode = params['barcode'] #need to check that this is valid barcode
  patron = Patron.for(session[:uniqname])
  item = Item.for(barcode)
  options = Options.for(patron: patron, item: item)
  erb :index, locals: {patron: patron, item: item, options: options}
end
