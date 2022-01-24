# frozen_string_literal: true

module Api
  module V1
    # API Interface for managing Store Baskets
    class BasketController < ApplicationController
      include Monetizable

      # Wrap all controller actions with logic to extract currency parameter
      around_action :with_currency

      # Generate basket information from products list
      #
      # GET /basket/check
      api :GET, '/v1/basket/check'
      description 'Calculates basket total price (Challenge III & IV).'
      param :product_codes,
            Array,
            required: true,
            desc: 'Collection of Product Codes, corresponding to the items in a basket.'
      param :currency,
            String,
            required: false,
            desc: 'Currency ISO code. Specifies currency in which'\
                  'prices will be returned. Only eur & usd codes allowed.'
      returns code: 200, desc: 'successful response' do
        property :total, :number, desc: 'Basket price (sum of all products) without discounts.'
        property :total_with_discount, :number, desc: 'Basket price (sum of all products) with discounts.'
        property :items, Array, of: Hash, desc: 'Collection of basket product items.' do
          property :amount, :number, desc: 'Amount of product in basket'
          property :product, Hash, desc: 'Product information' do
            property :id, :number, desc: 'Product ID.'
            property :name, String, desc: 'Product name.'
            property :code, String, desc: 'Product code.'
            property :price, String, desc: 'Product price in specified currency.'
          end
        end
        property :discounts, Hash, desc: 'Collection of basket applied discounts.' do
          property :id, :number, desc: 'Discount ID.'
          property :description, String, desc: 'Discount description.'
          property :reduction, String, desc: 'Readable % of discount to products.'
          property :applied_product_ids, Array, desc: 'Array of Product IDs corresponding'\
                                                      'to products in which discount is applied.'
        end
      end
      returns code: 400, desc: 'Invalid request parameters.'
      returns code: 422, desc: 'Unprocessable entity. Update parameters not valid.'
      def check
        set_basket
        render
      end

      private

      def set_basket
        @basket = NonPersistent::Basket.from_product_codes(product_codes: basket_params.map(&:downcase))
      end

      # Only allow a list of trusted parameters through
      def basket_params
        params.require(:product_codes)
      end
    end
  end
end
