# frozen_string_literal: true

module LaissCms
  # If the model has a +related_elements+ association,
  # it updates all their timestamps after save.
  #
  # Should only be used on bottom to top relations,
  # e.g. +LaissCms::Picture+ or +LaissCms::Attachment+
  # not on top to bottom ones like +LaissCms::Page+.
  #
  module TouchElements
    def self.included(base)
      base.after_update(:touch_elements)
    end

    private

    def touch_elements
      return unless respond_to?(:related_elements)

      related_elements.touch_all
    end
  end
end
