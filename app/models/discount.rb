# frozen_string_literal: true

# Models a store discount
#
# Discounts are applied to baskets. Applicable discounts can be only applied once to a basket
# (meaning, for example, that two 2x1 discounts in mugs can not be applied in the same basket)
#
# @attr min_amount
# 	@return [Integer] minimum amount of products in basket to apply discount
# @attr max_amount
# 	@return [Integer] maximum amount of products in basket to which discount can be applied.
# 										If not specified there is no limit to the amount of products discount can be applied
# @attr description
# 	@return [String] discount description
# @attr reduction
# 	@return [Float] % of product price reduced by discount
# @attr products
# 	@return [Array<Product>] discount applicable products
class Discount < ApplicationRecord
  has_many :product_discounts, dependent: :nullify
  has_many :products, through: :product_discounts

  # Model Validators
  # ----------------
  validates :min_amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_amount, presence: false, allow_blank: true, numericality: { only_integer: true }
  validate :max_amount_greater_or_equal_than_min_amount

  # Custom validation. Verifies the maximum discount product amount
  # is always greater or equal than the minimum product amount
  def max_amount_greater_or_equal_than_min_amount
    if min_amount && max_amount && min_amount > max_amount
      errors.add(:max_amount, 'min_amount greater than max_amount')
    end
  end

  # Can discount be applied to basket?
  #
  # @param basket [NonPersistent::Basket] basket with items
  # @return [true, false] is discount applicable to basket?
  def can_be_applied?(basket:)
    !applicable_products(basket: basket).blank?
  end

  # Subset of basket item products to which discount can be applied
  #
  # @param basket [NonPersistent::Basket] basket with items
  # @return [Array<Product>] collection of basket item products to which discount can be applied
  def applicable_products(basket:)
    # Select basket products whose code are compatible with discount
    basket_applicable_products =
      products.blank? ? basket.item_products : basket.item_products.select { |p| products.include? p }

    # Select products whose amount in basket matches with discount min-max amounts
    basket_applicable_products.select do |p|
      (min_amount.zero? ? true : min_amount <= basket_applicable_products.count(p))
    end
  end

  # Returns an array of the multiple product combinations discount can be applied to basket items
  #
  # @param basket [NonPersistent::Basket] basket with items to which discount will be applied
  # @return [Array<Array<Product>>] all possible combinations of basket items to which discount can be applied
  def applicable_product_permutations(basket:)
    products = applicable_products(basket: basket)

    return [] if products.blank?

    bottom_permutation_size = min_amount.zero? ? 1 : min_amount
    top_permutation_size = max_amount.presence || products.count

    Array(bottom_permutation_size..top_permutation_size)
      .map { |ps| products.permutation(ps).to_a }.flatten(1).uniq
  end
end
