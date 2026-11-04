module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class LockedPages < ViewComponent::Base
          delegate :laiss_cms, :can?, :current_laiss_cms_user, :render_icon, :multi_site?,
            to: :helpers

          def initialize
            @all_locked_pages = Page.locked
          end

          private

          def colspan = multi_site? ? 5 : 4
        end
      end
    end
  end
end
