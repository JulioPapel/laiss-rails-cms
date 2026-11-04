# frozen_string_literal: true

module LaissCms
  module Ingredients
    # A simple line of text
    #
    # Optionally it can have a link
    #
    class Text < LaissCms::Ingredient
      include DomIds

      store_accessor :data,
        :dom_id,
        :link,
        :link_target,
        :link_title,
        :link_class_name

      allow_settings %i[
        anchor
        disable_link
        display_inline
        input_type
        linkable
      ]

      validates_with LaissCms::SafeUrlValidator, attributes: [:link]
    end
  end
end
