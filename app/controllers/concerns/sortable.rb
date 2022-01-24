# frozen_string_literal: true

# Use this concern to add sort logic to your controllers
module Sortable
  extend ActiveSupport::Concern

  def sorted_resources(resources:, default_column: :created_at, default_order: :desc)
    sort_method = 'sort_by_column'
    parameters = sort_params
    sort_by = parameters[:sort_column] || default_column
    sort_order = parameters[:sort_order] || default_order

    if resources.respond_to?(sort_method) && sort_by && sort_order
      resources = resources.send(sort_method, sort_by, sort_order)
    end

    resources
  end

  private

  def sort_params
    params.slice(:sort_column, :sort_order)
  end
end
