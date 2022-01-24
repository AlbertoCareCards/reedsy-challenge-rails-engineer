# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'checks basket selected products match with discount criteria' do
  it 'checks basket selected products match with discount criteria' do
    subject.min_amount = min_amount
    subject.max_amount = max_amount
    discount_products&.each { |p| subject.products << p }

    result = subject.applicable_products(basket: basket)

    expect(subject.products.blank?).to be false
    expect(result).to match_array(expected_selected_products)
    expect(result.count).to eq(expected_selected_products.count)
  end
end
