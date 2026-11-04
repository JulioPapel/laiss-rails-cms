# frozen_string_literal: true

module LaissCms
  module Admin
    module MainNavigation
      class Menu < ViewComponent::Base
        erb_template <<~ERB
          <div id="main_navi">
            <%= render LaissCms::Admin::MainNavigation::Entry.with_collection(items) %>
            <%= helpers.content_for(:laiss_cms_main_navigation) %>
          </div>
        ERB

        def items
          positioned, unpositioned = LaissCms.config.menu.partition(&:position)
          positioned.sort_by(&:position) + unpositioned
        end
      end
    end
  end
end
