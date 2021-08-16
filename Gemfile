source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'sinatra'
gem 'httparty'
gem 'thin'
gem 'activesupport' #in here because of timezone support
gem 'omniauth'
gem 'omniauth_openid_connect'

gem 'alma_rest_client',
  git: 'https://github.com/mlibrary/alma_rest_client', 
  tag: '1.0.1'

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
