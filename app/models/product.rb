# frozen_string_literal: true

# Models a store product
#
# @!attr name
#   @return [String] human readable product name
# @!attr code
#   @return [String] product unique text identifier
# @!attr price
#   @return [Money] product price tag
# @!attr discounts
#   @return [Array<Discounts] product associated discounts
class Product < ApplicationRecord
  has_many :product_discounts, dependent: :nullify
  has_many :discounts, through: :product_discounts

  # This attribute is used to trigger the
  # invalid currency in price update requests
  attr_accessor :invalid_currency

  # Model Scopes
  # ------------
  scope :filter_by_name, ->(name) { where('lower(name) like ?', "%#{name.downcase}%") }
  scope :filter_by_code, ->(code) { where('lower(code) like ?', "%#{code.downcase}%") }
  scope :sort_by_column, ->(column = :created_at, order = :desc) { order("#{column} #{order}") }

  # Model Validators
  # ----------------
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validate :currency_code, if: :invalid_currency

  # Monetized attribute & price validation rules
  monetize :price_cents,
           as: :price,
           presence: true,
           # Make sure all prices are positive numbers
           numericality: { greater_than_or_equal_to: 0 }

  # Updates price allowing both cents price and currency specification
  #
  # @param [Hash] new_price new price in specific currency
  # @option new_price [String] :price_cents new product price (in cents). If not specified keep current price
  # @option new_price [String] :currency new product price currency
  def _update_price=(new_price)
    new_currency = new_price[:currency]
    new_price_cents = new_price[:price_cents] || price.exchange_to(new_currency).cents
    update(price: Money.new(new_price_cents, new_price[:currency]))
  rescue Money::Currency::UnknownCurrency
    # Set invalid currency to true and trigger manual update to generate incorrect currency error
    @invalid_currency = true
    update({})
  end

  private

  # Custom error validation for invalid currency code specification
  def currency_code
    errors.add(:price, 'must be specified in a currency accepted by system (eur or usd)')
  end
end
