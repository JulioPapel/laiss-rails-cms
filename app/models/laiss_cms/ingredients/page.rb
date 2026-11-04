# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A link to a page
    #
    # Assign LaissCms::Page to this ingredient
    #
    class Page < LaissCms::Ingredient
      related_object_alias :page, class_name: "LaissCms::Page"

      allow_settings %i[query_params]

      # The first 30 characters of page name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        page&.name.to_s[0..max_length - 1]
      end
    end
  end
end
