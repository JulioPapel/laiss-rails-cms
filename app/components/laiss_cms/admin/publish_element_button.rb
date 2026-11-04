module LaissCms
  module Admin
    class PublishElementButton < ViewComponent::Base
      delegate :laiss_cms, :cannot?, :render_icon, :link_to_dialog, to: :helpers

      attr_reader :element

      def initialize(element:)
        @element = element
      end
    end
  end
end
