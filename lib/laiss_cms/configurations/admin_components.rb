# frozen_string_literal: true

module LaissCms
  module Configurations
    # === Admin Component Registry
    #
    # Overridable admin ViewComponents, keyed by role. Extensions can swap a
    # component for their own by assigning a different class name in an
    # initializer:
    #
    #     LaissCms.config.admin_components.element_publish_button =
    #       "MyEngine::Admin::CustomPublishButton"
    #
    # Core renders these through the registry instead of referencing the class
    # directly, so the swap takes effect everywhere the component is used.
    class AdminComponents < LaissCms::Configuration
      # The per-element publish control rendered in the element toolbar.
      option :element_publish_button, :class, default: "LaissCms::Admin::PublishElementButton"

      # The page publication/visibility fields rendered in the page settings form.
      option :page_publication_fields, :class, default: "LaissCms::Admin::PagePublicationFields"

      # The visibility state badges rendered in the element header.
      option :element_status_indicators, :class, default: "LaissCms::Admin::ElementStatusIndicators"

      # The status badges rendered for a page in the page listing and sitemap.
      option :page_status_indicators, :class, default: "LaissCms::Admin::PageStatusIndicators"
    end
  end
end
