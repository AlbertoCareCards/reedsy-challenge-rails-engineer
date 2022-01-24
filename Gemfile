# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'rack-cors'

group :development, :test do
  # IDE Debugger connector
  gem 'ruby-debug-ide', '>= 0.7.3'
  gem 'debase', '~> 0.2.5.beta2'

  # RSpec Test configuration
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  # Documentation
  gem 'yard'
  gem 'solargraph'
end

group :rubocop do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-shopify', require: false
  gem 'rubocop-performance', require: false
end

# Money wrapper for Rails. Logic for managing currencies.
gem 'money-rails', '~>1.12'

# Simplifies controller logic for pagination (ej: /products?page=2&page_size=20).
gem 'kaminari'

# Generate test coverage reports
gem 'simplecov', require: false, group: :test

# Generate API documentation
gem 'apipie-rails'
