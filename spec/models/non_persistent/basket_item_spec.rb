# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BasketItem' do
  describe 'initialize' do
    context 'if product is not specified' do
      let(:product) { nil }
      let(:amount)  { 1 }

      subject { NonPersistent::BasketItem.new(product: product, amount: amount) }

      it 'basket item is created with no product' do
        expect(subject.product).to eq(nil)
      end
    end

    context 'if product is specified' do
      let(:product) { Product.new }
      let(:amount)  { 1 }

      subject { NonPersistent::BasketItem.new(product: product, amount: amount) }

      it 'basket item is created with specified product' do
        expect(subject.product).to eq(product)
      end
    end

    context 'if amount is not specified' do
      let(:product) { Product.new }
      let(:amount)  { nil }

      subject { NonPersistent::BasketItem.new(product: product, amount: amount) }

      it 'basket item is created with amount 0' do
        expect(subject.amount).to eq(0)
      end
    end

    context 'if amount is specified' do
      let(:product) { Product.new }
      let(:amount)  { 1 }

      subject { NonPersistent::BasketItem.new(product: product, amount: amount) }

      it 'basket item is created with specified amount' do
        expect(subject.amount).to eq(amount)
      end
    end
  end
end
