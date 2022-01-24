# frozen_string_literal: true

module NonPersistent
  # Models a shopping basket
  #
  # @!attr items
  #   @return [Array<NonPersistent::BasketItem>] basket items
  class Basket
    attr_accessor :items

    # Class initializer
    #
    # @param items [Array<BasketItem>] list of items in basket
    # @return [NonPersistent::Basket]
    def initialize(items: [])
      @items = items
    end

    # Create basket from array of product codes
    #
    # @param product_codes [Array<String>] list of product codes to be included in basket
    # @return [NonPersistent::Basket] basket with products corresponding to product_codes
    def self.from_product_codes(product_codes: [])
      selected_codes = (product_codes || []).map(&:to_s)
      selected_products = Product.where(code: product_codes)

      unless valid_product_codes?(product_codes: selected_codes, found_products: selected_products)
        raise Error::Model::Basket::InvalidProductCodesError.new(product_codes: selected_codes,
                                                                 products: selected_products)
      end

      from_products(products: selected_codes.map { |pc| selected_products.find { |p| p.code == pc } })
    end

    # Create basket from array of products
    #
    # @param product_codes [Array<Product>] list of products to be included in basket
    # @return [NonPersistent::Basket] basket with corresponding products
    def self.from_products(products: [])
      items = products.uniq.map { |p| BasketItem.new(product: p, amount: products.count(p)) }
      new(items: items)
    end

    # Verifies product codes for basket creation correspond to existing database products
    #
    # @param product_codes [Array<String>] collection of product codes
    # @param found_products [Array<Product>] products retrieved from database via product_codes
    # @return [true, false]
    def self.valid_product_codes?(product_codes:, found_products:)
      product_codes.uniq.count == found_products.count
    end

    # List of basket item products (maps one product per item)
    #
    # @return [Array<Product>] list of products associated to each basket item
    def item_products
      items.map { |i| Array.new(i.amount) { |_x| i.product } }.flatten
    end

    # List of basket item product codes (maps one product code per item)
    #
    # @return [Array<String>] list of product codes associated to each basket item
    def item_product_codes
      item_products.map(&:code)
    end

    # List of discounts associated to basket item products
    #
    # @return [Array<Discount>] list of discounts associated to each basket item product
    def item_discounts
      items.map(&:product).map(&:discounts).flatten.uniq
    end

    # Calculates the sum of basket product prices in given currency
    #
    # @param currency [String] currency in which basket price will be calculated
    # @return [Money] total basket price
    def total_price(currency: MoneyRails.default_currency)
      total_price_cents = items.map { |item| [item.product.price.exchange_to(currency).cents, item.amount] }
                               .map { |item_amount| item_amount.inject(:*) }
                               .sum
      Money.new(total_price_cents, currency)
    end

    # Calculates optimal set of discounts applicable to basket.
    #
    # The algorithm creates a decision tree with all the possible combinations of products
    # and discounts in basket, and performs a simple search to find the cheapest branch.
    #
    # @param discount_blacklist [Array<Discount>] List of discounts already applied to basket
    # @param currency [String] currency in which discount final price will be calculated
    # @return [Float, Array<Array<NonPersistent::BasketDiscount>>]
    #   Optimal basket price and set of basket discounts to be applied for it
    def optimal_discounts(discount_blacklist: [], currency: MoneyRails.default_currency)
      # Get list of all discounts not applied and available for basket items
      potential_discounts = item_discounts.select do |d|
        !discount_blacklist.include?(d) && d.can_be_applied?(basket: self)
      end

      lowest_price = nil
      optimal_discounts = []

      # No more discounts can be applied, calculate remaining basket price
      return [total_price(currency: currency).cents, []] if potential_discounts.blank?

      # Discounts can be applied, calculate multiple discount-basket item combinations and select the cheapest.
      potential_discounts.each do |d|
        basket_permutations = d.applicable_product_permutations(basket: self)

        basket_permutations.each do |permutation|
          permutation_results = permutation_optimal_discount(
            products: permutation,
            discount: d,
            discount_blacklist: discount_blacklist,
            lowest_price: lowest_price,
            optimal_discounts: optimal_discounts,
            currency: currency)

          lowest_price = permutation_results[0]
          optimal_discounts = permutation_results[1]
        end
      end

      [lowest_price, optimal_discounts]
    end

    # Calculates the sum of basket product prices in given currency by applying
    # the optimal combination of applicable discounts.
    #
    # @param currency [String] currency in which basket price will be calculated
    # @return [Money] total basket price with optimal discounts applied
    def total_price_with_discounts(currency: MoneyRails.default_currency)
      Money.new(optimal_discounts(currency: currency)[0], currency)
    end

    private

    # Creates a new basket from removing specified products from current basket
    #
    # @param removed_products [Array<Product>] collection of products to be removed from sub-basket
    # @return [NonPersistent::Basket] new basket with applied discounts and basket item - removed product items
    def remaining_basket(removed_products:)
      remaining_products = item_products
      removed_products.each do |rm|
        remaining_products.delete_at(remaining_products.index(rm) || remaining_products.size)
      end
      self.class.from_products(products: remaining_products)
    end

    # Returns the optimal basket price by applying passed discount to products and calculates
    # the suboptimal basket price from the remaining items in the basket (basket items - products)
    #
    # @param products [Array<Product>] applicable discount products
    # @param discount [Discount] discount to apply
    # @param discount_blacklist [Array<Discount>] list of already applied discounts
    # @param lowest_price [Float] current lowest basket price calculated
    # @param optimal_discounts [Array<Discount>] list of optimal discounts calculated
    # @param currency [String] currency in which basket price will be calculated
    # @return [Float, Array<Array<NonPersistent::BasketDiscount>>]
    #   Optimal basket price and set of basket discounts to be applied for it
    def permutation_optimal_discount(products:,
                                     discount:,
                                     discount_blacklist:,
                                     lowest_price:,
                                     optimal_discounts:,
                                     currency:)
      sub_optimal_discounts = remaining_basket(removed_products: products)
                                .optimal_discounts(discount_blacklist: discount_blacklist + [discount])

      discount_permutation_price = products
                                     .map(&:price)
                                     .map { |p| p.exchange_to(currency) }
                                     .map(&:cents).sum * (1 - discount.reduction)

      remaining_permutation_price = sub_optimal_discounts[0]
      final_price = discount_permutation_price.to_f + remaining_permutation_price.to_f

      if !lowest_price || final_price < lowest_price
        new_discount = NonPersistent::BasketDiscount.new(discount: discount, product_permutation: products)
        [final_price, (sub_optimal_discounts[1]) + [new_discount]]
      else
        [lowest_price, optimal_discounts]
      end
    end
  end
end
