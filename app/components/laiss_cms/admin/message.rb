module LaissCms
  module Admin
    class Message < ViewComponent::Base
      attr_reader :message, :type, :dismissable

      erb_template <<~ERB
        <laiss-cms-message type="<%= type %>"<%= dismissable ? ' dismissable' : '' %>>
          <%= message || content %>
        </laiss-cms-message>
      ERB

      def initialize(message = nil, type: :info, dismissable: false)
        @message = message
        @dismissable = dismissable
        @type = type
      end
    end
  end
end
