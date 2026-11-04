# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A HTML string
    #
    class Html < LaissCms::Ingredient
      # The first 30 escaped characters from value
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        ::CGI.escapeHTML(value.to_s)[0..max_length - 1]
      end
    end
  end
end
