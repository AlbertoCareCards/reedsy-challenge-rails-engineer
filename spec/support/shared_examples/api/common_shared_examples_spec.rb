# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'successful request' do
  it 'returns successful request code' do
    expect(response).to have_http_status(:success)
  end
end

RSpec.shared_examples 'unprocessable entity request' do
  it 'returns unprocessable entity request code' do
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

RSpec.shared_examples 'bad request' do
  it 'returns bad request code' do
    expect(response).to have_http_status(:bad_request)
  end
end

RSpec.shared_examples 'JSON error response' do
  let(:code) { '' }
  let(:status) { '' }

  it 'response returns error JSON with proper code and status' do
    response_body = JSON.parse(response.body)
    expect(response_body['code']).to eq(code)
    expect(response_body['status']).to eq(status)
  end
end
