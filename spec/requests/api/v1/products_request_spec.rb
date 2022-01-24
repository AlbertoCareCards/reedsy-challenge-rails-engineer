# frozen_string_literal: true

require 'rails_helper'
require './spec/support/shared_contexts/api/common_shared_contexts_spec'
require './spec/support/shared_examples/api/common_shared_examples_spec'
require './spec/support/shared_contexts/api/v1/products_shared_contexts_spec'
require './spec/support/shared_examples/api/v1/products_shared_examples_spec'

RSpec.describe Api::V1::ProductsController do
  describe 'GET /products' do
    fixtures :products

    context '/api/v1/products' do
      include_context 'GET /products request'
      include_examples 'successful request'
      include_examples 'list response includes total items number'

      it 'returns all products in store' do
        response_body = JSON.parse(response.body)
        expect(response_body).to have_key('data')

        products = response_body.dig('data')
        expect(products.count).to eq(Product.count)
      end

      it 'does not include any pagination parameter' do
        response_body = JSON.parse(response.body)
        expect(response_body).not_to have_key('page')
        expect(response_body).not_to have_key('page_size')
      end
    end

    context '/api/v1/products?page=&page_size' do
      context 'when a page and page size are specified' do
        include_context 'GET /products request' do
          let(:page) { 1 }
          let(:page_size) { 1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters'

        it 'returns page products' do
          response_body = JSON.parse(response.body)
          product_ids = response_body['data'].map { |p| p.dig('id') }
          expected_product_ids = Product.page(page).per(page_size).map(&:id)

          expect(product_ids).to match_array(expected_product_ids)
        end
      end

      context 'when specified page is greater than last page' do
        include_context 'GET /products request' do
          let(:page_size) { 1 }
          let(:last_page) { Product.page.per(page_size).total_pages }
          let(:page) { last_page + 1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters' do
          let(:page) { last_page }
        end
      end

      context 'when invalid page size is specified' do
        include_context 'GET /products request' do
          let(:page) { -1 }
          let(:page_size) { 1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters' do
          let(:page) { Api::V1::ProductsController::DEFAULT_PAGE }
        end
      end

      context 'when no page size is specified' do
        include_context 'GET /products request' do
          let(:page) { 1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters' do
          let(:page_size) { Api::V1::ProductsController::DEFAULT_PAGE_SIZE }
        end
      end

      context 'when invalid page size is specified' do
        include_context 'GET /products request' do
          let(:page) { 1 }
          let(:page_size) { -1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters' do
          let(:page_size) { Api::V1::ProductsController::DEFAULT_PAGE_SIZE }
        end
      end

      context 'when page size is greater than total of products' do
        include_context 'GET /products request' do
          let(:page) { 1 }
          let(:page_size) { Product.count + 1 }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'list response includes pagination parameters'

        it 'all results are returned' do
          response_body = JSON.parse(response.body)
          expect(response_body.dig('data').count).to eq(Product.count)
        end
      end
    end

    context '/api/v1/products?currency=' do
      context 'when no currency is specified' do
        include_context 'GET /products request'
        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'prices are displayed in currency'
      end

      context 'when valid currency is specified' do
        include_context 'GET /products request' do
          let(:currency) { :eur }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'prices are displayed in currency' do
          let(:currency) { :eur }
        end
      end

      context 'when invalid currency is specified' do
        include_context 'GET /products request' do
          let(:currency) { :cryptoscam }
        end

        include_examples 'successful request'
        include_examples 'list response includes total items number'
        include_examples 'prices are displayed in currency'
      end
    end
  end

  describe 'PUT /products' do
    context '/api/v1/products' do
      context 'when price is updated with a valid price' do
        include_context 'PUT /products request' do
          let(:currency) { :eur }
          let(:price_cents) { 100 }
        end

        include_examples 'successful request'
        include_examples 'product is updated with specified price' do
          let(:currency) { :eur }
          let(:price_cents) { 100 }
        end
      end

      context 'when price is updated with a invalid currency' do
        include_context 'PUT /products request' do
          let(:currency) { :cryptoscam }
          let(:price_cents) { 100 }
        end

        include_examples 'unprocessable entity request'
        include_examples 'price error validation message is returned'
      end

      context 'when price is updated without currency' do
        include_context 'PUT /products request' do
          let(:price_cents) { 100 }
        end

        include_examples 'unprocessable entity request'
        include_examples 'price error validation message is returned'
      end

      context 'when price is updated with a invalid price in cents' do
        include_context 'PUT /products request' do
          let(:currency) { :eur }
          let(:price_cents) { -100 }
        end

        include_examples 'unprocessable entity request'
        include_examples 'price error validation message is returned'
      end

      context 'when price is updated without price in cents' do
        include_context 'PUT /products request' do
          let(:currency) { :eur }
          let(:initial_price) { Product.first.price }
        end

        it 'Product is updated with same price but in specified currency' do
          result = Product.first.price.exchange_to(currency).cents
          expect(result).to eq initial_price.exchange_to(currency).cents
        end
      end
    end
  end
end
