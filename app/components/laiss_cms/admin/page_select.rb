module LaissCms
  module Admin
    class PageSelect < ViewComponent::Base
      delegate :laiss_cms, to: :helpers

      def initialize(page = nil, url: nil, allow_clear: false, placeholder: LaissCms.t(:search_page), query_params: nil, multiple: false)
        @page = page
        @url = url
        @allow_clear = allow_clear
        @placeholder = placeholder
        @query_params = query_params
        @multiple = multiple
      end

      def call
        content_tag("laiss-cms-page-select", attributes) do
          stylesheet_link_tag("laiss_cms/admin/page-select") + content
        end
      end

      private

      def attributes
        options = {
          placeholder: @placeholder,
          url: @url || laiss_cms.api_pages_path
        }

        options = options.merge({"allow-clear": @allow_clear}) if @allow_clear
        options = options.merge({"query-params": @query_params.to_json}) if @query_params
        options = options.merge({multiple: true}) if @multiple

        if @multiple
          if @page.present?
            selection = Array(@page).map { |page| page_selection(page) }
            options = options.merge({selection: selection.to_json})
          end
        elsif @page
          options = options.merge({selection: page_selection(@page).to_json})
        end

        options
      end

      def page_selection(page)
        {
          id: page.id,
          name: page.name,
          url_path: page.url_path
        }
      end
    end
  end
end
