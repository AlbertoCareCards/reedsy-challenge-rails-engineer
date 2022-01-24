# frozen_string_literal: true

# encoding : utf-8

MoneyRails.configure do |config|
  # To set the default currency
  config.default_currency = :USD

  # List of available currencies & conversion rates
  # TODO: in future use rate API and a system to add/remove currencies dynamically
  config.add_rate "USD", "EUR", 0.87
  config.add_rate "EUR", "USD", 1.14
end
