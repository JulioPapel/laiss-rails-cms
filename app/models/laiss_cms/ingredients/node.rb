# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A link to a menu node
    #
    # Assign LaissCms::Node to this ingredient
    #
    class Node < LaissCms::Ingredient
      related_object_alias :node, class_name: "LaissCms::Node"

      allow_settings %i[query_params]

      # The first 30 characters of node name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        node&.name.to_s[0..max_length - 1]
      end
    end
  end
end
