# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'basket response' do
  it 'has all basket response fields' do
    response_body = JSON.parse(response.body)
    expect(response_body).to have_key('total')
    expect(response_body).to have_key('items')
    expect(response_body).to have_key('total_with_discount')
    expect(response_body).to have_key('discounts')
  end
end

RSpec.shared_examples 'has correct total' do
  let(:total) { 0 }
  let(:currency) { MoneyRails.default_currency }

  it 'expected total price matches with response price' do
    response_body = JSON.parse(response.body)
    response_body.to_json
    expected_total = ApplicationController.helpers.readable_price(price: Money.new(total, currency), currency: currency)
    expect(response_body['total']).to eq(expected_total)
  end
end

RSpec.shared_examples 'has correct discount total' do
  let(:total_with_discount) { 0 }
  let(:currency) { MoneyRails.default_currency }

  it 'expected total price matches with response price' do
    response_body = JSON.parse(response.body)
    expected_total = ApplicationController
                       .helpers
                       .readable_price(price: Money.new(total_with_discount, currency), currency: currency)
    expect(response_body['total_with_discount']).to eq(expected_total)
  end
end

RSpec.shared_examples 'has correct products' do
  it 'expected total price matches with response price' do
    response_body = JSON.parse(response.body)
    result = response_body.dig('items').map { |i| Array.new(i['amount']) { |_x| i.dig('product', 'code') } }.flatten
    expect(result).to match_array(product_codes)
  end
end

RSpec.shared_examples 'has correct discounts' do
  let(:expected_discount_ids) do
    NonPersistent::Basket.from_product_codes(product_codes: product_codes)
                         .optimal_discounts[1].map { |bd| bd.discount.id }
  end

  it 'expected total price matches with response price' do
    response_body = JSON.parse(response.body)
    result = response_body['discounts'].map { |d| d['id'] }
    expect(result).to match_array(expected_discount_ids)
  end
end
