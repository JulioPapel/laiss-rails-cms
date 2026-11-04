# frozen_string_literal: true

module LaissCms
  module Admin
    module Dashboard
      class Widget < ViewComponent::Base
        delegate :laiss_cms, to: :helpers

        erb_template <<~ERB
          <div class="widget <%= @style %>">
            <turbo-frame id="<%= @id %>" src="<%= url %>" loading="<%= @loading %>">
              <laiss-cms-spinner size="small"></laiss-cms-spinner>
            </turbo-frame>
          </div>
        ERB

        def initialize(id:, loading: "eager", style: "default", condition: nil)
          @id = id
          @loading = loading
          @style = style
          @condition = condition

          if condition && !condition.respond_to?(:call)
            raise ArgumentError, ":condition argument must be a proc or lambda"
          end
        end

        private

        def render?
          return true if @condition.nil?

          instance_exec(&@condition)
        end

        def url = laiss_cms.admin_dashboard_widget_path(id: @id)
      end
    end
  end
end
