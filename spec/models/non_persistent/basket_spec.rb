# frozen_string_literal: true

require 'rails_helper'
require './spec/support/shared_examples/models/non_persistent/basket_shared_examples_spec'
require './spec/support/shared_contexts/models/non_persistent/basket_shared_contexts_spec'

RSpec.describe 'Basket' do
  fixtures :products
  fixtures :discounts
  fixtures :product_discounts

  describe 'from_product_codes' do
    context 'if product codes correspond to non existent products' do
      let(:product_codes) { [:invalid_product_code] }

      it 'Invalid product code basket error is raised' do
        expect { NonPersistent::Basket.from_product_codes(product_codes: product_codes) }
          .to raise_error(Error::Model::Basket::InvalidProductCodesError)
      end
    end

    context 'if no product codes are specified' do
      subject { NonPersistent::Basket.from_product_codes(product_codes: nil) }

      it 'empty basket is created' do
        expect(subject.items.count).to eq(0)
      end
    end

    context 'if valid product codes are specified' do
      let(:products) { [Product.first, Product.first, Product.last] }
      let(:product_codes) { products.map(&:code) }

      it 'invokes form_products method with product code related products' do
        expect(NonPersistent::Basket).to receive(:from_products)
                                          .with(products: products)
        NonPersistent::Basket.from_product_codes(product_codes: product_codes)
      end
    end
  end

  describe 'from_products' do
    context 'if products are specified' do
      let(:products) { [Product.first, Product.first, Product.last] }

      it 'a basket item is created per product and new basket with items is returned' do
        products.uniq.each do |p|
          expect(NonPersistent::BasketItem).to receive(:new).once.with(product: p, amount: products.count(p))
        end
        result = NonPersistent::Basket.from_products(products: products)
        expect(result).to be_a(NonPersistent::Basket)
      end
    end

    context 'if no products are specified' do
      let(:products) { [] }

      it 'an empty basket is returned' do
        result = NonPersistent::Basket.from_products(products: products)
        expect(result.items).to be_empty
      end
    end
  end

  describe 'valid_product_codes?' do
    context 'when product codes do not match with found products' do
      include_context 'basket product code validation initialization'
      include_examples 'return expected validation result'
    end

    context 'when product codes match with found products' do
      include_context 'basket product code validation initialization' do
        let(:validation_result) { false }
        let(:product_codes) { products.map(&:code) + [:invalid_product_code] }
      end
      include_examples 'return expected validation result'
    end
  end

  describe 'item_products' do
    context 'when basket has items' do
      let(:products) { [Product.first, Product.first, Product.last] }
      let(:product_codes) { products.map(&:code) }

      subject { NonPersistent::Basket.from_product_codes(product_codes: product_codes) }

      it 'returns array of products corresponding to each index in the basket' do
        result = subject.item_products
        expect(result).to match_array(products)
      end
    end

    context 'when basket has no items' do
      let(:product_codes) { [] }

      subject { NonPersistent::Basket.from_product_codes(product_codes: product_codes) }

      it 'empty array is returned' do
        result = subject.item_products
        expect(result).to be_empty
      end
    end
  end

  describe 'item_product_codes' do
    context 'when invoked' do
      let(:products) { [Product.first, Product.first, Product.last] }
      let(:product_codes) { products.map(&:code) }

      subject { NonPersistent::Basket.from_product_codes(product_codes: product_codes) }

      it 'requests item products and maps products returned to code' do
        expect(subject).to receive(:item_products).and_return(products)
        result = subject.item_product_codes
        expect(result).to match_array(product_codes)
      end
    end
  end

  describe 'total_price' do
    context 'given a basket with multiple products and specific currency' do
      include_context 'randomized basket'
      include_examples 'calculates the sum of all basket item prices in given currency'
      include_examples 'returns the sum of all basket item prices in given currency'
    end

    context 'given a basket with multiple products and no currency' do
      include_context 'randomized basket'
      include_examples 'calculates the sum of all basket item prices in default currency'
      include_examples 'returns the sum of all basket item prices in default currency'
    end

    context 'given an empty basket and no currency' do
      include_context 'randomized basket' do
        let(:products) { [] }
      end
      include_examples 'calculates the sum of all basket item prices in given currency'
      include_examples 'returns the sum of all basket item prices in given currency'
    end
  end

  describe 'optimal_discounts' do
    context 'testing multiple combinations of products & scenarios according to challenge' do
      context 'Challenge products & discounts, basket I (No deals applicable)' do
        subject { NonPersistent::Basket.from_product_codes(product_codes: [:mug, :tshirt, :hoodie]) }

        it 'Total of 4100 price cents and no discounts applied' do
          expect(subject).to receive(:item_discounts).and_return(Discount.all.to_a)
          result = subject.optimal_discounts
          expect(result[0]).to eq(subject.total_price.cents)
          expect(result[1]).to be_empty
        end
      end

      context 'Challenge products & discounts, basket II (one deal applicable)' do
        subject { NonPersistent::Basket.from_product_codes(product_codes: [:mug, :tshirt, :mug]) }

        it 'Total of 2100 price cents and no discounts applied (deal applied)' do
          expect(subject).to receive(:item_discounts).and_return(Discount.all.to_a)
          result = subject.optimal_discounts
          expect(result[0]).to eq(2100)
          expect(result[1].count).to eq(1)
        end
      end

      context 'Challenge products & discounts, basket III' do
        subject { NonPersistent::Basket.from_product_codes(product_codes: [:mug, :tshirt, :mug, :mug]) }

        it 'Total of 2700 price cents and no discounts applied' do
          expect(subject).to receive(:item_discounts).and_return(Discount.all.to_a)
          result = subject.optimal_discounts
          expect(result[0]).to eq(2700)
          expect(result[1].count).to eq(1)
        end
      end

      context 'Challenge products & discounts, basket IV (repeated deal)' do
        subject { NonPersistent::Basket.from_product_codes(product_codes: [:mug, :tshirt, :mug, :mug, :mug]) }

        it 'Total of 3300 price cents and no discounts applied (repeated deal only applied once)' do
          expect(subject).to receive(:item_discounts).and_return(Discount.all.to_a)
          result = subject.optimal_discounts
          expect(result[0]).to eq(3300)
          expect(result[1].count).to eq(1)
        end
      end

      context 'Challenge products & discounts, basket V (multiple deals repeated)' do
        subject do
          NonPersistent::Basket
            .from_product_codes(product_codes: %w[mug tshirt tshirt tshirt tshirt mug hoodie])
        end

        it 'Total of 6800 price cents and no discounts applied (each deal is applied only once)' do
          expect(subject).to receive(:item_discounts).and_return(Discount.all.to_a)
          result = subject.optimal_discounts
          expect(result[0]).to eq(6800)
          expect(result[1].count).to eq(2)
        end
      end
    end

    describe 'total_price_with_discounts' do
      let(:currency) { MoneyRails.default_currency }

      subject { NonPersistent::Basket.from_product_codes(product_codes: [:mug, :tshirt, :mug, :mug, :mug]) }

      it 'optimal discount method is called and result is converted to specified currency' do
        expect(subject).to receive(:optimal_discounts).with(currency: currency).and_return([100])
        result = subject.total_price_with_discounts(currency: currency)
        expect(result.cents).to eq(100)
      end
    end
  end
end
