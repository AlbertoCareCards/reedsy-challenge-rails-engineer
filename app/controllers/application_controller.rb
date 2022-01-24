# frozen_string_literal: true

# Application controller
class ApplicationController < ActionController::API
  # Enable error handling in production and test environments
  include Error::ErrorHandler unless Rails.env.development?

  helper PriceHelper
end
