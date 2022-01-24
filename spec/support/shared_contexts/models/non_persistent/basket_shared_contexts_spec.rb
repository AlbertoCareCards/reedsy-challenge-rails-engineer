# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'GET /basket request', shared_context: :metadata do
  let(:product_codes) { [] }
  let(:params) { {} }

  before do
    get '/api/v1/basket/check', params: params
  end
end

RSpec.shared_context 'basket discount initialization', shared_context: :metadata do
  let(:discount) { Discount.new }
  let(:applicable_discount) { false }
end

RSpec.shared_context 'basket product code validation initialization', shared_context: :metadata do
  let(:products) { [Product.first] }
  let(:product_codes) { products.map(&:code) + products.map(&:code) }
  let(:validation_result) { true }
end

RSpec.shared_context 'randomized basket', shared_context: :metadata do
  let(:products) { Product.all.sample(Product.count + 4) }
  let(:product_codes) { products.map(&:code) }
  let(:currency) { :usd }

  subject { NonPersistent::Basket.from_product_codes(product_codes: product_codes) }
end
