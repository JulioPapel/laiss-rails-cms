module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class ElementUsage < UsageWidget
          private

          def header_text(total:)
            LaissCms.t(:element_usage, total:)
          end

          def definitions
            LaissCms::ElementDefinition.all
          end

          def public_counts
            @public_counts ||= LaissCms::Element.published.group(:name).count
          end

          def draft_counts
            @draft_counts ||= LaissCms::Element
              .where("laiss_cms_elements.public_on IS NULL OR laiss_cms_elements.public_until <= ?", Time.current)
              .group(:name).count
          end

          def entry_label(entry)
            LaissCms::Element.display_name_for(entry.name)
          end

          def entry_icon(entry)
            entry.definition.icon_file
          end
        end
      end
    end
  end
end
