require "sinatra"
require "sinatra/reloader" if development?
require "alma_rest_client"
require "byebug" if development?
require "active_support/all"
require "omniauth"
require "omniauth_openid_connect"
require "sinatra/flash"
require "faraday/follow_redirects"
require "ostruct"

Time.zone = "Eastern Time (US & Canada)"

require_relative "lib/styled_flash"
require_relative "lib/utility"
require_relative "models/patron"
require_relative "models/item"
require_relative "models/options/media_booking"
require_relative "models/options"
require_relative "lib/closed_days"

helpers StyledFlash
enable :sessions
set :session_secret, ENV["RACK_COOKIE_SECRET"]
set server: "puma", connections: []

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: ENV["OIDC_ISSUER"],
    discovery: true,
    client_auth_method: "jwks",
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV["OIDC_CLIENT_ID"],
      secret: ENV["OIDC_CLIENT_SECRET"],
      redirect_uri: "#{ENV["GET_THIS_BASE_URL"]}/auth/openid_connect/callback"
    }
  }
end
get "/auth/openid_connect/callback" do
  auth = request.env["omniauth.auth"]
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  session[:uniqname] = info[:nickname]
  redirect session.delete(:path_before_login) || "/"
end

# :nocov:
get "/auth/failure" do
  "You are not authorized"
end
# :nocov:

get "/logout" do
  session.clear
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"
end

get "/login" do
  erb :login, locals: {has_js: true}
end

before do
  Time.zone = "Eastern Time (US & Canada)"
  pass if ["auth", "session_switcher", "logout", "login", "-", "favicon.svg"].include? request.path_info.split("/")[1]

  if dev_login?
    session[:uniqname] = "mlibrary.acct.testing1@gmail.com" unless session[:uniqname]
    pass
  end

  if !session[:authenticated] || Time.now.utc > session[:expires_at]
    session[:path_before_login] = request.path_info
    redirect "/login"
  end
end

helpers do
  def dev_login?
    ENV["WEBLOGIN_ON"] == "false" && settings.environment == :development
  end
end

# :nocov:
post "/session_switcher" do
  session[:uniqname] = params[:uniqname]
  redirect "/#{params[:item]}"
end
# :nocov:

get "/confirmation" do
  erb :confirmation
end

get "/:barcode" do
  barcode = params["barcode"] # need to check that this is valid barcode
  patron = Patron.for(session[:uniqname])
  item = Item.for(barcode)
  options = Options.for(patron: patron, item: item)
  erb :index, locals: {patron: patron, item: item, options: options}
end

get "/" do
  if dev_login?
    erb :dev_home
  else
    redirect "https://www.lib.umich.edu/find-borrow-request"
  end
end

post "/booking" do
  barcode = ""
  barcode = URI.parse(request.referrer).path.delete("/") if request.referrer
  begin
    logger.info "Requesting barcode: #{barcode}; for pickup on #{params[:date]}; for pickup at #{params["pickup-location"]}"
    response = Option::MediaBooking.book(uniqname: session[:uniqname], barcode: barcode, booking_date: params[:date], pickup_location: params["pickup-location"])
  rescue
    response = OpenStruct.new(code: 500, body: "rejected before sent to Alma")
  end
  if response.status != 200
    logger.error response.body
    flash[:critical] = "Item was not able to be scheduled for pickup"
    redirect request.referrer
  else
    data = response.body
    title = data["title"]
    pickup_date = Time.zone.parse(data["booking_start_date"]).to_date.strftime("%A, %B %-d, %Y")
    pickup_location = data["pickup_location"]
    logger.info "Barcode: #{data["barcode"]}; Title: #{title}; Booked for #{pickup_date}; for pickup at #{pickup_location}"
    flash[:success] = "Your pickup of <strong>#{title}</strong> has been scheduled for <strong>#{pickup_date}</strong> at <strong>#{pickup_location}</strong>"
    redirect "/confirmation"
  end
end
get "/-/live" do
  200
end
