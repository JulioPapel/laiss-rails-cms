module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class UserCounts < StatWidget
          private

          def link = LaissCms.config.admin_users_path
          def icon = "group"
          def title = LaissCms.config.user_class.model_name.human(count: :many)
          def count = LaissCms.config.user_class.count

          def infos
            if LaissCms.config.user_class.respond_to?(:logged_in)
              safe_join([
                number_with_delimiter(LaissCms.config.user_class.logged_in.length),
                t(".online")
              ], " ")
            end
          end
        end
      end
    end
  end
end
