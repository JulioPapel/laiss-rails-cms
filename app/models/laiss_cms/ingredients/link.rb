# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A URL
    #
    class Link < LaissCms::Ingredient
      store_accessor :data,
        :link_class_name,
        :link_target,
        :link_title

      allow_settings %i[text]

      validates_with LaissCms::SafeUrlValidator, attributes: [:value]

      alias_method :link, :value
    end
  end
end
