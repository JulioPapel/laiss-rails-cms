# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A datetime value
    #
    class Datetime < LaissCms::Ingredient
      allow_settings %i[date_format input_type]

      def value
        ActiveRecord::Type::DateTime.new.cast(self[:value])
      end

      # Returns localized date for the Element#preview_text method.
      def preview_text(_maxlength = nil)
        return "" unless value

        LaissCms.l(value, format: :"laiss_cms.ingredient_date")
      end
    end
  end
end
