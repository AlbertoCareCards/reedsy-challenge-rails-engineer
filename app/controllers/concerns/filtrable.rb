# frozen_string_literal: true

# Use this concern to add filter logic to your controllers
module Filtrable
  extend ActiveSupport::Concern

  # Given a active record class reads filter parameters (to be defined by controller)
  # and infers class filter scopes to be called in order to filter results.
  def filtered_resources(resources:)
    if defined?(filter_params)
      filters = filter_params.reject { |_, v| v.blank? }
      filters.keys.each do |scope|
        scope_method = "filter_by_#{scope}"
        resources = resources.send(scope_method, filters[scope]) if resources.respond_to?(scope_method)
      end
    end

    resources
  end
end
