source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'sinatra'
gem 'httparty'
gem 'puma'
gem 'activesupport' #in here because of timezone support
gem "omniauth", "~>1.9"
gem "omniauth_openid_connect", "~>0.3.5"
gem 'sinatra-flash'

gem 'alma_rest_client',
  git: 'https://github.com/mlibrary/alma_rest_client', 
  tag: '1.3.1'

# In order to get rspec to work for ruby 3.1. Maybe later see if it's still necessary
gem "net-smtp", require: false

group :development do
  gem 'sinatra-contrib'
  gem 'listen'
end
group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-test'
  gem 'rspec'
  gem 'webmock'
  gem 'simplecov'
  gem 'climate_control'
end
