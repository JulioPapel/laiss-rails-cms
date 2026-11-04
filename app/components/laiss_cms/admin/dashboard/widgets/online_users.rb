module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class OnlineUsers < ViewComponent::Base
          delegate :current_laiss_cms_user, to: :helpers

          private

          def online_users
            if LaissCms.config.user_class.respond_to?(:logged_in)
              LaissCms.config.user_class.logged_in.to_a - [current_laiss_cms_user]
            end
          end
        end
      end
    end
  end
end
