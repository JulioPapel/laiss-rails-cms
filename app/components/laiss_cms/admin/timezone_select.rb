module LaissCms
  module Admin
    # Renders a timezone select dropdown triggered by an icon button.
    class TimezoneSelect < ViewComponent::Base
      def call
        tag.div(class: "laiss-cms-timezone-select") do
          content_tag("sl-tooltip", content: current_timezone, placement: "left") do
            content_tag("sl-dropdown", distance: 5) do
              safe_join([trigger_button, popover_content])
            end
          end
        end
      end

      private

      def trigger_button
        content_tag("sl-button", slot: "trigger", size: "small", variant: "text") do
          content_tag("laiss-cms-icon", nil, name: "time-zone", size: "1x", slot: "prefix", style: "color: var(--icon-color)")
        end
      end

      def popover_content
        content_tag(:div, class: "laiss-cms-popover") do
          form_tag(request.path, method: :get, class: "timezone-select") do
            label_tag(:admin_timezone, LaissCms.t(:timezone)) +
              content_tag("laiss-cms-auto-submit") do
                select_tag(
                  :admin_timezone,
                  options_for_select(timezones_for_select, current_timezone),
                  is: "laiss-cms-select"
                )
              end
          end
        end
      end

      def timezones_for_select
        ActiveSupport::TimeZone.all.map(&:name)
      end

      def current_timezone
        Time.zone.name
      end
    end
  end
end
