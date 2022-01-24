# frozen_string_literal: true

# Partial to render resources lists
# ---------------------------------
# Locals:
# - name: list name
# - total: number of resources in database
# - page: resources result page
# - page_size: number of results per page
# - resource_template: JBuilder partial to render resources
# - resource_name: local variable name for resource partial
#
json.total total if total
json.page page if page
json.page_size page_size if page_size
json.set!(name || :data) do
  json.array! resources, partial: resource_template, as: resource_name
end
