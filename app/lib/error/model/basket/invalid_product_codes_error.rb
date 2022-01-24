# frozen_string_literal: true

module Error
  module Model
    module Basket
      # Error triggered when trying to create a basket with wrong product codes
      class InvalidProductCodesError < Error::CustomError
        def initialize(product_codes: [], products: [])
          super(422,
                :unprocessable_entity,
                error_message(product_codes: product_codes, products: products))
        end

        private

        def error_message(product_codes: [], products: [])
          wrong_product_codes = product_codes - products.map(&:code)
          "One or more product codes do not match with existing products: [#{wrong_product_codes.join(', ')}]"
        end
      end
    end
  end
end
