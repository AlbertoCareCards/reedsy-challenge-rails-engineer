# frozen_string_literal: true

json.id basket_discount.discount.id
json.description basket_discount.discount.description
json.reduction number_to_percentage(basket_discount.discount.reduction * 100, precision: 0)
json.applied_product_ids basket_discount.product_permutation.map(&:id)
