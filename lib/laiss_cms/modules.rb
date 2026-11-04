# frozen_string_literal: true

module LaissCms
  module Modules
    class << self
      def included(base)
        base.send :helper_method, :laiss_cms_modules, :module_definition_for
      end

      # Register a LaissCms module.
      #
      # A module is a Hash that must have at least a name and a navigation key
      # that has a controller and action name.
      #
      # == Example:
      #
      #     name: 'module',
      #     navigation: {
      #       controller: 'admin/controller_name',
      #       action: 'index'
      #     }
      #
      def register_module(module_definition)
        menu_item = LaissCms::Configurations::MenuItem.from_legacy_hash(module_definition)
        return if menu_item.name.present? && LaissCms.config.menu.any? { |item| item.name == menu_item.name }

        LaissCms.config.menu.add(menu_item)
      end
      deprecate register_module: "Use `LaissCms.config.menu.add` instead", deprecator: LaissCms::Deprecation

      def laiss_cms_modules
        LaissCms.config.menu.map { |menu_item| to_legacy_hash(menu_item) }
      end
      deprecate laiss_cms_modules: "Use `LaissCms.config.menu` instead", deprecator: LaissCms::Deprecation

      def to_legacy_hash(menu_item)
        {
          "name" => menu_item.name,
          "engine_name" => menu_item.engine_name,
          "position" => menu_item.position,
          "navigation" => to_legacy_navigation(menu_item)
        }.compact
      end

      private

      def to_legacy_navigation(menu_item)
        {
          "name" => menu_item.title,
          "controller" => menu_item.controller,
          "action" => menu_item.action,
          "url" => menu_item.url,
          "condition" => menu_item.condition,
          "icon" => menu_item.icon,
          "icon-style" => menu_item.icon_style,
          "image" => menu_item.image,
          "inline_image" => menu_item.inline_image,
          "data" => menu_item.turbo ? nil : {turbo: false},
          "nested_controllers" => menu_item.nested_controllers.to_a.presence,
          "nested_actions" => menu_item.nested_actions.to_a.presence,
          "sub_navigation" => menu_item.children.map { |child| to_legacy_navigation(child) }.presence,
          "nested" => menu_item.nested.map { |entry| to_legacy_navigation(entry) }.presence
        }.compact
      end
    end

    def laiss_cms_modules
      LaissCms::Modules.laiss_cms_modules
    end

    # Get the module definition for given module name
    #
    # You can also pass a hash of an module definition.
    # It then tries to find the module defintion from controller name and action name
    #
    def module_definition_for(name_or_params)
      menu_item = case name_or_params
      when String
        LaissCms.config.menu.detect { |item| item.name == name_or_params }
      when Hash
        params = name_or_params.stringify_keys
        LaissCms.config.menu.detect do |item|
          [item, *item.children, *item.nested].any? do |entry|
            entry.matches_controller?(controller: params["controller"], action: params["action"])
          end
        end
      else
        raise ArgumentError, "Could not find module definition for #{name_or_params}"
      end
      LaissCms::Modules.to_legacy_hash(menu_item) if menu_item
    end
    deprecate module_definition_for: "Use `LaissCms.config.menu` instead", deprecator: LaissCms::Deprecation
  end
end
