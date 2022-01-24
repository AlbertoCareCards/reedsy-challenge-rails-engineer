# frozen_string_literal: true

module NonPersistent
  # Auxiliar class to better model how discounts are applied to basket
  #
  # @!attr discount
  #   @return [Discount] discount applicable to product permutation
  # @!attr product_permutation
  #   @return [Array<Product>] subset of basket item products to which discount is applied
  class BasketDiscount
    attr_reader :discount, :product_permutation

    # Class initializer
    #
    # @param discount [Discount]
    # @param product_permutation [Array<Product>]
    def initialize(discount:, product_permutation:)
      @discount = discount
      @product_permutation = product_permutation
    end
  end
end
