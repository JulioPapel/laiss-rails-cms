module LaissCms
  module Ingredients
    class BooleanView < BaseView
      def call
        LaissCms.t(value.to_s, scope: "ingredient_values.boolean").html_safe
      end

      def render?
        !value.nil?
      end
    end
  end
end
