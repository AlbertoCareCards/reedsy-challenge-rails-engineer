# frozen_string_literal: true

module NonPersistent
  # Auxiliar class. Models a basket item
  #
  # @!attribute product
  #   @return [Product] basket product
  # @attr amount
  #   @return [Integer] product quantity in basket
  class BasketItem
    attr_reader :product, :amount

    # Class initializer
    #
    # @param product [Product] basket item product
    # @param amount [Integer] total of product in basket
    def initialize(product:, amount:)
      @product = product
      @amount = amount || 0
    end
  end
end
