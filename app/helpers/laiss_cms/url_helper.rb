# frozen_string_literal: true

# LaissCms url helpers
#
# This helper is included within laiss_cms/pages_helper
#
module LaissCms
  module UrlHelper
    # Returns the path for rendering an laiss_cms page
    def show_laiss_cms_page_path(page, optional_params = {})
      page.url_path(optional_params)
    end

    # Returns the url for rendering an laiss_cms page
    def show_laiss_cms_page_url(page, optional_params = {})
      "#{request.base_url}#{page.url_path(optional_params)}"
    end

    # Returns the path for downloading an laiss_cms attachment
    def download_laiss_cms_attachment_path(attachment)
      laiss_cms.download_attachment_path(attachment, attachment.slug)
    end

    # Returns the url for downloading an laiss_cms attachment
    def download_laiss_cms_attachment_url(attachment)
      laiss_cms.download_attachment_url(attachment, attachment.slug)
    end
  end
end
