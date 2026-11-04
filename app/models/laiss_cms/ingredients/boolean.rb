# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A boolean value
    #
    class Boolean < LaissCms::Ingredient
      def value
        val = self[:value].nil? ? definition.default : self[:value]
        ActiveRecord::Type::Boolean.new.cast(val)
      end

      # The localized value
      #
      # Used by the Element#preview_text method.
      #
      def preview_text(_max_length = nil)
        return if value.nil?

        LaissCms.t(value.to_s, scope: "ingredient_values.boolean")
      end
    end
  end
end
