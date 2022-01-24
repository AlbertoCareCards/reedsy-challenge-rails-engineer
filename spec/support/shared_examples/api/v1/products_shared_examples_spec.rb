# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'list response includes total items number' do
  it 'returns total number of products in system' do
    response_body = JSON.parse(response.body)
    expect(response_body).to include('total' => Product.count)
  end
end

RSpec.shared_examples 'list response includes pagination parameters' do
  it 'returns results page and page size' do
    response_body = JSON.parse(response.body)
    expect(response_body).to include('page' => page, 'page_size' => page_size)
  end
end

RSpec.shared_examples 'prices are displayed in currency' do
  let(:currency) { MoneyRails.default_currency }

  it 'prices are displayed in currency' do
    response_body = JSON.parse(response.body)
    subject = response_body['data'].first
    expected_readable_price = ApplicationController
                                .helpers
                                .readable_price(
                                  price: Product.find(subject['id']).price,
                                  currency: currency)
    expect(subject['price']).to eq expected_readable_price
  end
end

RSpec.shared_examples 'product is updated with specified price' do
  let(:currency)    { nil }
  let(:price_cents) { nil }

  it 'product is updated with specified price' do
    result = Product.first.price.exchange_to(currency).cents
    expect(result).to eq price_cents
  end
end

RSpec.shared_examples 'price error validation message is returned' do
  it 'price error validation message is returned' do
    response_body = JSON.parse(response.body)
    expect(response_body).to have_key('price')
    expect(response_body).to_not have_key('name')
    expect(response_body).to_not have_key('code')
  end
end
