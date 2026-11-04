# frozen_string_literal: true

module LaissCms
  module CacheDigests
    class TemplateTracker
      def self.call(name, template)
        new(name, template).dependencies
      end

      def initialize(name, template)
        @name, @template = name, template
      end

      def dependencies
        case @name.to_s
        when /^laiss_cms\/pages\/show/
          PageDefinition.all.map { "laiss_cms/page_layouts/_#{_1.name}" }
        when /^laiss_cms\/page_layouts\/_(\w+)/
          page_definition = PageDefinition.get($1)
          page_definition.elements.map { "laiss_cms/elements/_#{_1}" }
        else
          ActionView::DependencyTracker::ERBTracker.call(@name, @template)
        end
      end

      private

      def ingredient_types(name)
        element = Element.definitions.detect { _1.name == name }
        return [] unless element

        element.ingredients.map(&:type)
      end
    end
  end
end
