# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, :type => :model do
  fixtures :products

  describe 'model validations' do
    subject { Product.first }

    it 'name attribute: has to be present' do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it 'name attribute: has to be unique' do
      unique_subject = Product.new(name: subject.name, code: 'another-mug-code', price: 0)
      expect(unique_subject).to_not be_valid
    end

    it 'code attribute: has to be present' do
      subject.code = nil
      expect(subject).to_not be_valid
    end

    it 'code attribute: has to be unique' do
      unique_subject = Product.new(name: 'another-test-mug', code: subject.code, price: 0)
      expect(unique_subject).to_not be_valid
    end

    it 'price attribute: always is present' do
      subject.price = nil
      expect(subject.price).to be_instance_of Money

      result = Product.new(name: :test, code: subject.code, price: nil)
      expect(result.price).to be_instance_of Money
    end

    it 'price attribute: has to be equal or greated than 0' do
      subject.price = Money.new(-1, 'EUR')
      expect(subject).to_not be_valid
    end
  end

  describe '_update_price=' do
    subject { Product.first }

    before { subject.save }

    context 'if price is updated with valid price and currency' do
      it 'product is updated with new price' do
        result = subject.update(_update_price: { price_cents: 100, currency: :eur })

        expect(result).to be true
      end
    end

    context 'if price is updated with invalid price' do
      it 'product is not updated and invalid price error is returned' do
        result = subject.update(_update_price: { price_cents: -100, currency: :eur })

        expect(result).to be false
        expect(subject.errors).to include('price')
      end
    end

    context 'if price is updated with invalid currency' do
      it 'product is not updated and invalid currency error is returned' do
        result = subject.update(_update_price: { price_cents: 100, currency: :cryptoscam })

        expect(result).to be false
        expect(subject.errors).to include('price')
      end
    end
  end
end
