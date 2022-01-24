# frozen_string_literal: true

module Api
  module V1
    # API Interface for managing Store Products
    class ProductsController < ApplicationController
      include Sortable
      include Filtrable
      include Paginated
      include Monetizable

      before_action :set_product, only: %i[update]

      # Wrap all controller actions with logic to extract currency parameter
      around_action :with_currency

      # List of products
      #
      # GET /products
      api :GET, '/v1/products'
      description 'Return list of products in database (Challenge I)'
      param :page,
            :number,
            desc: 'Pagination param, sorts results by pages and returns specified page results.'\
              'If specified page is lower than 1 API will return page 1 results. If specified'\
              'page is higher than last page API will return last page results',
            required: false
      param :page_size, :number, desc: 'Pagination param, specifies size of result pages.', required: false
      param :name, String, desc: 'Filter products, select ones whose name matches with parameter value.',
            required: false
      param :code, String, desc: 'Filter products, select ones whose code matches with parameter value.',
            required: false
      param :sort_column, String, desc: 'Select Product column/attribute you want to sort products by (name or code).',
            required: false
      param :sort_order, String, desc: 'Select sorting order (asc for ascending and desc for descending).',
            required: false
      param :currency,
            String,
            required: false,
            desc: 'Currency ISO code. Specifies currency in which prices will be returned. '\
              'Only eur & usd codes allowed. Using other codes will return prices in '\
              "default currency (#{MoneyRails.default_currency})"
      returns code: 200, desc: 'successful response' do
        property :total, :number, desc: 'Total number of products in database.'
        property :page, :number, desc: 'Results page (only present when using pagination parameters).'
        property :page_size, :number, desc: 'Results page size (only present when using pagination parameters).'
        property :data, Hash, desc: 'Collection of product information.' do
          property :id, :number, desc: 'Product ID.'
          property :name, String, desc: 'Product name.'
          property :code, String, desc: 'Product code.'
          property :price, String, desc: 'Product price in specified currency.'
        end
      end
      def index
        filtered_products = filtered_resources(resources: Product.all)
        sorted_items = sorted_resources(resources: filtered_products)
        @products = paginated_items(resources: sorted_items)
        render
      end

      # GET /products/1
      # def show
      #   render json: @product
      # end

      # POST /products
      # def create
      #   @product = Product.new(product_params)
      #
      #   if @product.save
      #     render json: @product, status: :created, location: @product
      #   else
      #     render json: @product.errors, status: :unprocessable_entity
      #   end
      # end

      # Update product information (due to current challenge specification only price is updated)
      #
      # PATCH/PUT /products/1
      api :PUT, '/v1/products/:id'
      description 'Updates product price (Challenge II)'
      param :id, :number, desc: 'ID of updated product.', required: true
      param :product, Hash, desc: 'Updated product.', required: true do
        param :currency, String,
              desc: 'Currency ISO code. Specify currency in which product price will be updated.'
        param :price_cents, :number,
              desc: 'Updated product price in cents.'
      end
      returns code: 200, desc: 'successful response' do
        property :id, Integer, desc: 'Product ID.'
        property :name, String, desc: 'Product name.'
        property :code, String, desc: 'Product code.'
        property :price, :number, desc: 'Product price in specified currency.'
      end
      returns code: 400, desc: 'Invalid request parameters.'
      returns code: 404, desc: 'Product not found.'
      returns code: 422, desc: 'Unprocessable entity. Update parameters not valid.'
      def update
        set_updated_price
        if @product.update(_update_price: @updated_price)
          render
        else
          render json: @product.errors, status: :unprocessable_entity
        end
      end

      # DELETE /products/1
      # def destroy
      #   @product.destroy
      # end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      # Load price update parameters in a model compatible format
      def set_updated_price
        @updated_price = {
          currency: product_params['currency'].to_s,
          price_cents: product_params['price_cents'].to_s,
        }
      end

      # Only allow a list of trusted parameters through
      def product_params
        # Disable default Product params to only enable price update
        # params.require(:product).permit(:name, :price_cents, :code)
        params.require(:product).permit(:currency, :price_cents)
      end

      # Parses filter parameters
      #
      # @return [Hash] filter parameters
      def filter_params
        {
          name: params[:name],
          code: params[:code],
        }
      end
    end
  end
end
