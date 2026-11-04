module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class PageUsage < UsageWidget
          delegate :laiss_cms, to: :helpers

          private

          def header_text(total:)
            LaissCms.t(:page_usage, total:)
          end

          def definitions
            LaissCms::PageDefinition.all
          end

          def public_counts
            @public_counts ||= LaissCms::Page.published.group(:page_layout).count
          end

          def draft_counts
            @draft_counts ||= LaissCms::Page
              .where.not(id: LaissCms::Page.published.select(:id))
              .where.not(id: LaissCms::PageVersion.where("public_on > ?", Time.current).select(:page_id))
              .group(:page_layout).count
          end

          def entry_label(entry)
            link_to entry.definition.human_name,
              laiss_cms.admin_pages_path(view: "list", q: {by_page_layout: entry.name}),
              data: {turbo_frame: "_top"}
          end

          def tooltip_content(entry)
            "#{entry.definition.human_name}: #{entry.public_count} #{LaissCms.t(:published)}, #{entry.draft_count} #{LaissCms.t(:draft)}"
          end

          def entry_icon(entry)
            helpers.content_tag(:"laiss-cms-icon", "", name: "file")
          end
        end
      end
    end
  end
end
