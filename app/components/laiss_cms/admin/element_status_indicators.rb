# frozen_string_literal: true

module LaissCms
  module Admin
    # Renders the visibility state badges (hidden / scheduled) shown for an
    # element in the element header.
    class ElementStatusIndicators < ViewComponent::Base
      def initialize(element:)
        @element = element
      end

      private

      attr_reader :element

      def scheduled_tooltip
        LaissCms.t(
          element.public_on&.future? ? :public_on : :public_until,
          scope: :element_scheduled,
          public_on: LaissCms.l(element.public_on),
          public_until: LaissCms.l(element.public_until)
        )
      end

      def scheduled_label
        date = element.public_on&.future? ? element.public_on : element.public_until
        LaissCms.l(date, format: :"laiss_cms.short_datetime")
      end
    end
  end
end
