# frozen_string_literal: true

module LaissCms
  # Defines the methods that are needed to
  # make a model searchable in LaissCms's admin search by Ransack.
  module SearchableResource
    SEARCHABLE_COLUMN_TYPES = %i[string text]

    # Allow all string and text attributes to be searchable by Ransack.
    def ransackable_attributes(_auth_object = nil)
      searchable_laiss_cms_resource_attributes
    end

    # Allow all attributes to be sortable by Ransack.
    def ransortable_attributes(_auth_object = nil)
      columns.map(&:name)
    end

    # Allow all associations defined in +laiss_cms_resource_relations+ to be searchable by Ransack.
    def ransackable_associations(_auth_object = nil)
      searchable_laiss_cms_resource_associations
    end

    # Allow all scopes used in resource filters to be used with Ransack
    def ransackable_scopes(_auth_object = nil)
      if respond_to?(:laiss_cms_resource_filters)
        laiss_cms_resource_filters.flat_map do |filter_set|
          if respond_to?(filter_set[:name])
            filter_set[:name].to_s
          else
            filter_set[:values].map(&:to_s)
          end
        end
      else
        []
      end
    end

    protected

    def searchable_laiss_cms_resource_attributes
      columns.select { |c| c.type.in?(SEARCHABLE_COLUMN_TYPES) }.map(&:name)
    end

    def searchable_laiss_cms_resource_associations
      if respond_to?(:laiss_cms_resource_relations)
        laiss_cms_resource_relations.keys.map!(&:to_s)
      else
        []
      end
    end
  end
end
