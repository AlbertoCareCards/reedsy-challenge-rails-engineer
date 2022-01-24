# frozen_string_literal: true

discounts = @basket.optimal_discounts(currency: @currency)[1]
readable_total = ApplicationController
                   .helpers
                   .readable_price(price: @basket.total_price(currency: @currency),
                                   currency: @currency)
readable_total_with_discount = ApplicationController
                                 .helpers
                                 .readable_price(price: @basket.total_price_with_discounts(currency: @currency),
                                                 currency: @currency)

json.total readable_total
json.partial! 'common/list',
              locals: {
                name: 'items',
                total: nil,
                page: nil,
                page_size: nil,
                resources: @basket.items,
                resource_name: :item,
                resource_template: 'api/v1/basket/basket_item',
              }
json.total_with_discount readable_total_with_discount
json.partial! 'common/list',
              locals: {
                name: 'discounts',
                total: nil,
                page: nil,
                page_size: nil,
                resources: discounts,
                resource_name: :basket_discount,
                resource_template: 'api/v1/basket/basket_discount',
              }
