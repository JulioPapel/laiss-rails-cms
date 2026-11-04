module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class PageCounts < StatWidget
          private

          def link = laiss_cms.admin_pages_path
          def icon = "pages"
          def title = LaissCms::Page.model_name.human(count: :many)
          def count = LaissCms::Page.count

          def infos
            safe_join([
              number_with_delimiter(LaissCms::Page.published.count),
              t(".published")
            ], " ")
          end
        end
      end
    end
  end
end
