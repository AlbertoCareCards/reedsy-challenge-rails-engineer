# frozen_string_literal: true

# Use this concern to add pagination logic to your controllers
module Paginated
  extend ActiveSupport::Concern

  # Page to load results from when specified page is not in pages range
  DEFAULT_PAGE = 1
  # Page size to use when page_size parameter is not specified
  DEFAULT_PAGE_SIZE = 3

  private

  # Pagination logic. Loads pagination parameters in controller and applies
  # pagination to resources. If no page parameter is specified method does not paginate
  #
  # Ex.: `GET /resources?page=1&page_size=3`
  #
  # @return [ActiveRecord::Base] paginated collection of resources
  def paginated_items(resources:)
    load_resources_total(resources)

    return resources unless paginate?

    load_pagination_params(resources: resources)
    resources.page(@page).per(@page_size)
  end

  # Are pagination parameters specified?
  #
  # @return [true, false] is "page" parameter specified?
  def paginate?
    !params.slice('page').values.all?(&:blank?)
  end

  # Checks given page is between pagination range. Lower pages than default page will result in
  # pagination to default page. Higher pages than last page will result in pagination to last page
  #
  # @param resources [ActiveRecord::Base] collection of resources to paginate
  # @return [Integer] page from which results will be returned
  def computed_page(page_param:, resources:, page_size:)
    page = (page_param || DEFAULT_PAGE_SIZE).to_i
    last_page = resources.page(page).per(page_size).total_pages

    if page > last_page
      last_page
    elsif page < DEFAULT_PAGE
      DEFAULT_PAGE
    else
      page
    end
  end

  def computed_page_size(page_size_param:)
    page_size = (page_size_param || DEFAULT_PAGE_SIZE).to_i
    page_size >= 1 ? page_size : DEFAULT_PAGE_SIZE
  end

  # Load pagination parameters in controller for paginated results extraction
  # and JBuilder metadata
  def load_pagination_params(resources:)
    @page_size = computed_page_size(page_size_param: params['page_size'])
    @page = computed_page(page_param: params['page'], resources: resources, page_size: @page_size)
  end

  # Returns total of resources in database
  #
  # @param resources [ActiveRecord::Base] resources to be counted
  # @return [Integer] number of resources in database
  def load_resources_total(resources)
    @total = resources.size
  end
end
