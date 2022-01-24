# frozen_string_literal: true

json.id product.id
json.name product.name
json.code product.code
json.price ApplicationController.helpers.readable_price price: product.price, currency: @currency
