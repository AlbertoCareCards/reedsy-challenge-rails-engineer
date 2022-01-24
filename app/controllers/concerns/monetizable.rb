# frozen_string_literal: true

# Use this concern to add currency logic to your controllers
module Monetizable
  extend ActiveSupport::Concern

  private

  # Currency logic. Loads currency parameter in controller action allowing
  # controller render logic to display prices with specified currency
  #
  # EX.: `GET /products?currency=EUR`
  def with_currency
    @currency = params[:currency] || MoneyRails.default_currency
    yield
  end
end
