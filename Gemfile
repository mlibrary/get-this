source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "sinatra"
gem "faraday-follow_redirects"
gem "puma"
gem "yabeda-puma-plugin"
gem "yabeda-prometheus"
gem "activesupport" # in here because of timezone support
gem "omniauth"
gem "omniauth_openid_connect"
gem "sinatra-flash"
gem "rackup"

gem "alma_rest_client",
  git: "https://github.com/mlibrary/alma_rest_client",
  tag: "v2.0.0"

# In order to get rspec to work for ruby 3.3. Maybe later see if it's still necessary
gem "net-smtp", require: false

group :development do
  gem "sinatra-contrib"
  gem "listen"
end
group :development, :test do
  gem "standard"
  gem "pry"
  gem "pry-byebug"
  gem "rack-test"
  gem "rspec"
  gem "webmock"
  gem "simplecov"
  gem "climate_control"
end
