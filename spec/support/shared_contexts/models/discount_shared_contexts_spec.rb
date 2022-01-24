# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'discount test parameters for basket matching', shared_context: :metadata do
  let(:min_amount) { 1 }
  let(:max_amount) { 2 }
  let(:expected_selected_products) { [Product.first, Product.first] }
  let(:discount_products) { [Product.first, Product.last] }
  let(:basket_products) { [Product.first, Product.first, Product.last, Product.last, Product.last] }
  let(:basket) { NonPersistent::Basket.from_products(products: basket_products) }

  subject { Discount.new(min_amount: min_amount, max_amount: max_amount, description: 'test discount', reduction: 0.5) }
end
