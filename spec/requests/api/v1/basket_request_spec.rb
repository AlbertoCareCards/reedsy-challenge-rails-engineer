# frozen_string_literal: true

require 'rails_helper'
require './spec/support/shared_contexts/api/common_shared_contexts_spec'
require './spec/support/shared_examples/api/common_shared_examples_spec'
require './spec/support/shared_contexts/api/v1/basket_shared_contexts_spec'
require './spec/support/shared_examples/api/v1/basket_shared_examples_spec'

RSpec.describe Api::V1::BasketController do
  fixtures :products
  fixtures :discounts
  fixtures :product_discounts

  describe 'GET /check' do
    context '/api/v1/basket/check (no product codes)' do
      include_context 'GET /basket request'
      include_examples 'bad request'
      include_examples 'JSON error response' do
        let(:code) { 400 }
        let(:status) { 'bad_request' }
      end
    end

    context '/api/v1/basket/check?product_codes[]=valid_product_codes' do
      include_context 'GET /basket request' do
        let(:product_codes) { %w[mug hoodie tshirt] }
        let(:params) { { product_codes: product_codes } }
      end
      include_examples 'successful request'
      include_examples 'basket response'
      include_examples 'has correct total' do
        let(:total) { 4100 }
      end
      include_examples 'has correct products'
    end

    context '/api/v1/basket/check?product_codes[]=invalid_product_codes' do
      include_context 'GET /basket request' do
        let(:product_codes) { %w[invalid_code hoodie tshirt] }
        let(:params) { { product_codes: product_codes } }
      end
      include_examples 'unprocessable entity request'
    end

    context '/api/v1/basket/check?product_codes[]=UPPERCASE_PRODUCT_CODES' do
      include_context 'GET /basket request' do
        let(:product_codes) { %w[mug hoodie tshirt] }
        let(:params) { { product_codes: product_codes } }
      end
      include_examples 'successful request'
      include_examples 'basket response'
      include_examples 'has correct total' do
        let(:total) { 4100 }
      end
      include_examples 'has correct products'
    end

    context '/api/v1/basket/check?product_codes[]=&currency=' do
      include_context 'GET /basket request' do
        let(:currency) { 'eur' }
        let(:product_codes) { %w[mug hoodie tshirt] }
        let(:params) { { product_codes: product_codes, currency: currency } }
      end
      include_examples 'successful request'
      include_examples 'basket response'
      include_examples 'has correct total' do
        let(:total) { 4100 }
      end
      include_examples 'has correct products'
    end

    context 'Challenge Solutions' do
      context 'Question 4 Basket I' do
        include_context 'GET /basket request' do
          let(:product_codes) { %w[mug tshirt hoodie] }
          let(:params) { { product_codes: product_codes } }
        end
        include_examples 'successful request'
        include_examples 'basket response'
        include_examples 'has correct total' do
          let(:total) { 4100 }
        end
        include_examples 'has correct discount total' do
          let(:total_with_discount) { 4100 }
        end
        include_examples 'has correct products'
        include_examples 'has correct discounts'
      end

      context 'Question 4 Basket II' do
        include_context 'GET /basket request' do
          let(:product_codes) { %w[mug tshirt mug] }
          let(:params) { { product_codes: product_codes } }
        end
        include_examples 'successful request'
        include_examples 'basket response'
        include_examples 'has correct total' do
          let(:total) { 2700 }
        end
        include_examples 'has correct discount total' do
          let(:total_with_discount) { 2100 }
        end
        include_examples 'has correct products'
        include_examples 'has correct discounts'
      end

      context 'Question 4 Basket III' do
        include_context 'GET /basket request' do
          let(:product_codes) { %w[mug tshirt mug mug] }
          let(:params) { { product_codes: product_codes } }
        end
        include_examples 'successful request'
        include_examples 'basket response'
        include_examples 'has correct total' do
          let(:total) { 3300 }
        end
        include_examples 'has correct discount total' do
          let(:total_with_discount) { 2700 }
        end
        include_examples 'has correct products'
        include_examples 'has correct discounts'
      end

      context 'Question 4 Basket IV' do
        include_context 'GET /basket request' do
          let(:product_codes) { %w[mug tshirt mug mug mug] }
          let(:params) { { product_codes: product_codes } }
        end
        include_examples 'successful request'
        include_examples 'basket response'
        include_examples 'has correct total' do
          let(:total) { 3900 }
        end
        include_examples 'has correct discount total' do
          let(:total_with_discount) { 3300 }
        end
        include_examples 'has correct products'
        include_examples 'has correct discounts'
      end

      context 'Question 4 Basket V' do
        include_context 'GET /basket request' do
          let(:product_codes) { %w[mug tshirt tshirt tshirt tshirt mug hoodie] }
          let(:params) { { product_codes: product_codes } }
        end
        include_examples 'successful request'
        include_examples 'basket response'
        include_examples 'has correct total' do
          let(:total) { 9200 }
        end
        include_examples 'has correct discount total' do
          let(:total_with_discount) { 6800 }
        end
        include_examples 'has correct products'
        include_examples 'has correct discounts'
      end
    end
  end
end
