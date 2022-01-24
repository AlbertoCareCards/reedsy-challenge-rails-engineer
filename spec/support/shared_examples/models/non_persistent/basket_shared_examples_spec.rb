# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples('return expected validation result') do
  it 'return expected validation result' do
    result = NonPersistent::Basket.valid_product_codes?(product_codes: product_codes, found_products: products)
    expect(result).to(be(validation_result))
  end
end

RSpec.shared_examples('calculates the sum of all basket item prices in given currency') do
  it 'calculates the sum of all basket item prices' do
    result = subject.total_price(currency: currency).cents
    expect(result).to(eq(products.map(&:price).map { |p| p.exchange_to(currency) }.map(&:cents).sum))
  end
end

RSpec.shared_examples('calculates the sum of all basket item prices in default currency') do
  it 'calculates the sum of all basket item prices in default currency' do
    result = subject.total_price(currency: MoneyRails.default_currency).cents
    expect(result).to(eq(products.map(&:price).map { |p| p.exchange_to(MoneyRails.default_currency) }.map(&:cents).sum))
  end
end

RSpec.shared_examples('returns the sum of all basket item prices in given currency') do
  it 'returns the sum of all basket item prices in given currency' do
    result = subject.total_price(currency: currency).currency.symbol
    expect(result).to(eq(Money.new(0, currency).currency.symbol))
  end
end

RSpec.shared_examples('returns the sum of all basket item prices in default currency') do
  it 'returns the sum of all basket item prices in default currency' do
    result = subject.total_price(currency: MoneyRails.default_currency).currency.symbol
    expect(result).to(eq(Money.new(0, MoneyRails.default_currency).currency.symbol))
  end
end
