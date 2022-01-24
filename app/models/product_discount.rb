# frozen_string_literal: true

# Models many-to-many association between Product and Discount models
class ProductDiscount < ApplicationRecord
  belongs_to :product
  belongs_to :discount
end
