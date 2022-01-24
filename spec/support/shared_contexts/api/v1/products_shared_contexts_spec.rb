# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_context 'GET /products request', shared_context: :metadata do
  let(:page)      { nil }
  let(:page_size) { nil }
  let(:currency)  { nil }

  before do
    get '/api/v1/products', params: { page: page, page_size: page_size, currency: currency }.compact
  end
end

RSpec.shared_context 'PUT /products request', shared_context: :metadata do
  let(:currency) { nil }
  let(:price_cents) { nil }

  before do
    put "/api/v1/products/#{Product.first.id}",
        params: { product: { price_cents: price_cents, currency: currency }.compact }
  end
end
