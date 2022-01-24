# frozen_string_literal: true

json.partial! 'common/list',
              locals: {
                name: :data,
                total: @total,
                page: @page,
                page_size: @page_size,
                resources: @products,
                resource_name: :product,
                resource_template: 'api/v1/products/product',
              }
