# frozen_string_literal: true

# Helper for displaying prices in human readable format
module PriceHelper
  # Returns price value in <price number><currency_symbol> format
  #
  # @param price [Money] price to be displayed
  # @param currency [String] ISO currency code (if not specified uses default currency)
  # @return [String] price in readable format
  def readable_price(price:, currency: '')
    begin
      exchange_price = price.exchange_to(currency)
    rescue StandardError
      exchange_price = price.exchange_to(MoneyRails.default_currency)
    end

    exchange_price.format(symbol_position: :after)
  end
end
