# frozen_string_literal: true

module LaissCms
  module Admin
    # This module contains helper methods for rendering the admin navigation.
    #
    module NavigationHelper
      # Renders one admin main navigation entry
      #
      # @param [Hash] laiss_cms_module
      #   The Hash representing a LaissCms module
      #
      def laiss_cms_main_navigation_entry(laiss_cms_module)
        render LaissCms::Admin::MainNavigation::Entry.new(
          item: LaissCms::Configurations::MenuItem.from_legacy_hash(laiss_cms_module)
        )
      end
      deprecate laiss_cms_main_navigation_entry: "Render `LaissCms::Admin::MainNavigation::Entry` instead",
        deprecator: LaissCms::Deprecation

      # Returns url for given LaissCms module.
      #
      # @param [Hash]
      #   A LaissCms module definition
      #
      def url_for_module(laiss_cms_module)
        LaissCms::Configurations::MenuItem.from_legacy_hash(laiss_cms_module).path(self)
      end
      deprecate url_for_module: "Use `LaissCms::Configurations::MenuItem#path` instead",
        deprecator: LaissCms::Deprecation

      # LaissCms modules for main navigation.
      #
      # Sorted by position attribute, if given.
      #
      def sorted_laiss_cms_modules
        LaissCms::Admin::MainNavigation::Menu.new.items.map { |menu_item| LaissCms::Modules.to_legacy_hash(menu_item) }
      end
      deprecate sorted_laiss_cms_modules: "Use `LaissCms.config.menu` instead",
        deprecator: LaissCms::Deprecation

      private

      # Retrieves the current LaissCms module from controller and index action.
      #
      def current_laiss_cms_module
        module_definition_for(controller: params[:controller], action: "index")
      end
    end
  end
end
