module LaissCms
  module Ingredients
    class PageView < BaseView
      delegate :page, to: :ingredient

      def call
        link_to(page.name, laiss_cms.show_page_path(urlname: page.urlname)).html_safe
      end

      def render?
        !!page
      end
    end
  end
end
