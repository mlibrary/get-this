source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'sinatra'
gem 'httparty'
gem 'thin'

gem 'alma_rest_client',
  git: 'https://github.com/mlibrary/alma_rest_client', 
  tag: '1.0.1'

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'rack-test'
  gem 'rspec'
  gem 'sinatra-contrib'
  gem 'webmock'
  gem 'simplecov'
  gem 'climate_control'
  gem 'listen'
end
