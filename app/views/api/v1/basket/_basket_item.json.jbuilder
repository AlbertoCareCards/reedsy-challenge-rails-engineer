# frozen_string_literal: true

json.amount item.amount
json.product do
  json.partial! 'api/v1/products/product', locals: { product: item.product }
end
