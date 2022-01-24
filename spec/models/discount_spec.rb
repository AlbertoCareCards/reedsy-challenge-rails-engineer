# frozen_string_literal: true

require 'rails_helper'
require './spec/support/shared_examples/models/discount_shared_examples_spec'
require './spec/support/shared_contexts/models/discount_shared_contexts_spec'

RSpec.describe Discount, type: :model do
  describe 'model validations' do
    subject { Discount.new(min_amount: 3, max_amount: 5, description: 'test discount', reduction: 0.5) }

    before { subject.save }

    it 'min_amount attribute: has to be present' do
      subject.min_amount = nil
      expect(subject).to_not be_valid
    end

    it 'min_amount attribute: has to be integer' do
      subject.min_amount = 1.2
      expect(subject).to_not be_valid

      subject.min_amount = '1.2'
      expect(subject).to_not be_valid
    end

    it 'min_amount attribute: has to be greater or equal than 0' do
      subject.min_amount = -3
      expect(subject).to_not be_valid
    end

    it 'min_amount attribute: has to be lower than max_amount' do
      subject.min_amount = 3
      subject.max_amount = 2
      expect(subject).to_not be_valid
    end

    it 'max_amount attribute: has to be integer' do
      subject.max_amount = 1.2
      expect(subject).to_not be_valid

      subject.max_amount = '1.2'
      expect(subject).to_not be_valid
    end

    describe 'can_be_applied?' do
      context 'if basket has no applicable products' do
        it 'applicable products is empty and method returns false' do
          allow(subject).to receive(:applicable_products).and_return([])
          result = subject.can_be_applied?(basket: NonPersistent::Basket.new)
          expect(result).to be false
        end
      end

      context 'if basket returns applicable products' do
        it 'applicable products is not empty and method returns true' do
          allow(subject).to receive(:applicable_products).and_return([:not_empty])
          result = subject.can_be_applied?(basket: NonPersistent::Basket.new)
          expect(result).to be true
        end
      end
    end

    describe 'applicable_products' do
      fixtures :products

      context 'if discount has no products specified and match min-max amount range' do
        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 0 }
          let(:max_amount) { nil }
          let(:expected_selected_products) { Product.all.to_a }
          let(:discount_products) { nil }
          let(:basket_products) { Product.all.to_a }
          let(:basket) { NonPersistent::Basket.from_products(products: Product.all.to_a) }
        end

        include_examples 'discount test parameters for basket matching'
      end

      context 'if discount has products specified and match min-max amount range' do
        include_context 'discount test parameters for basket matching'
        include_examples 'discount test parameters for basket matching'
      end

      context 'if discount has no max amount specified' do
        include_context 'discount test parameters for basket matching' do
          let(:max_amount) { nil }
          let(:expected_selected_products) do
            [Product.first, Product.first, Product.last, Product.last, Product.last]
          end
        end

        include_examples 'discount test parameters for basket matching'
      end

      context 'if discount has min-max amount specified' do
        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 3 }
          let(:max_amount) { 3 }
          let(:expected_selected_products) { [Product.last, Product.last, Product.last] }
        end

        include_examples 'discount test parameters for basket matching'

        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 2 }
          let(:max_amount) { 2 }
          let(:expected_selected_products) { [Product.first, Product.first] }
        end

        include_examples 'discount test parameters for basket matching'
      end
    end

    describe 'applicable_product_permutations' do
      context 'if no products can be selected from basket' do
        it 'returns empty array of product permutations' do
          allow(subject).to receive(:applicable_products).and_return([])
          result = subject.applicable_product_permutations(basket: NonPersistent::Basket.new)
          expect(result).to be_empty
        end
      end

      context 'if products can be selected from basket' do
        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 1 }
          let(:max_amount) { 2 }
          let(:expected_selected_products) { [Product.first, Product.last] }
        end

        it 'performs permutations according to discount range' do
          allow(subject).to receive(:applicable_products).and_return(expected_selected_products)
          Array(min_amount..max_amount).each do |pm|
            expect(expected_selected_products).to receive(:permutation).once.ordered.with(pm)
          end
          subject.applicable_product_permutations(basket: NonPersistent::Basket.new)
        end
      end

      context 'if discount has 0 min amount specified' do
        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 0 }
          let(:max_amount) { 2 }
          let(:expected_selected_products) { [Product.first, Product.last] }
        end

        it 'uses 1 as default min amount' do
          allow(subject).to receive(:applicable_products).and_return(expected_selected_products)
          Array(1..max_amount).each do |pm|
            expect(expected_selected_products).to receive(:permutation).once.ordered.with(pm)
          end
          subject.applicable_product_permutations(basket: NonPersistent::Basket.new)
        end
      end

      context 'if discount has no max account specified' do
        include_context 'discount test parameters for basket matching' do
          let(:min_amount) { 1 }
          let(:max_amount) { nil }
          let(:expected_selected_products) { [Product.first, Product.last] }
        end

        it 'uses the total of products selected as the max amount' do
          allow(subject).to receive(:applicable_products).and_return(expected_selected_products)
          Array(min_amount..expected_selected_products.count).each do |pm|
            expect(expected_selected_products).to receive(:permutation).once.ordered.with(pm)
          end
          subject.applicable_product_permutations(basket: NonPersistent::Basket.new)
        end
      end
    end
  end
end
