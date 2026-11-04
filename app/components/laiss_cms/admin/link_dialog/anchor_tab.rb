# frozen_string_literal: true

module LaissCms
  module Admin
    module LinkDialog
      class AnchorTab < BaseTab
        def title
          LaissCms.t("link_overlay_tab_label.anchor")
        end

        def self.panel_name
          :anchor
        end

        def fields
          [
            dom_id_select,
            title_input
          ]
        end

        def message
          render_message(:info, LaissCms.t(:anchor_link_headline))
        end

        private

        def dom_id_select
          label = label_tag("anchor_link", LaissCms.t(:anchor), class: "control-label")
          options = [[LaissCms.t("None"), ""]]
          options += [[@url, @url]] if is_selected? && @url

          select = select_tag(:anchor_link, options_for_select(options, @url), is: "laiss-cms-select")
          select_component = content_tag("laiss-cms-dom-id-preview-select", select)

          content_tag("div", label + select_component, class: "input select")
        end
      end
    end
  end
end
