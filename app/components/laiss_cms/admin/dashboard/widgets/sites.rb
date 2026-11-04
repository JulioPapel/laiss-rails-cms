module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class Sites < ViewComponent::Base
          delegate :laiss_cms, :current_laiss_cms_user, to: :helpers

          private

          def sites = Site.all
        end
      end
    end
  end
end
