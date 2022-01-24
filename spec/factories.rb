# frozen_string_literal: true

FactoryBot.define do
  factory :product_discount do
    product { nil }
    discount { nil }
  end

  factory :discount do
    min_amount { 1 }
    max_amount { 1 }
    description { "MyString" }
    reduction { 1.5 }
  end

  factory :product, class: "Product" do
    name  { "Joe" }
    code  { "tshirt" }
    price { 100 }
  end
end
