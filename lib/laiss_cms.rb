# frozen_string_literal: true

require "importmap-rails"
require "laiss_cms/configurations/main"
require "laiss_cms/config_missing"

module LaissCms
  include LaissCms::ConfigMissing
  extend LaissCms::ConfigMissing

  YAML_PERMITTED_CLASSES = %w[Symbol Date Regexp]

  # JS Importmap instance
  singleton_class.attr_accessor :importmap
  self.importmap = Importmap::Map.new

  mattr_accessor :storage_adapter

  class << self
    def config
      @_config ||= LaissCms::Configurations::Main.new
    end
    delegate :configure, to: :config

    enable_searchable_deprecation_msg = "Use `LaissCms.config.show_page_searchable_checkbox` instead."
    def enable_searchable = config.show_page_searchable_checkbox
    deprecate :enable_searchable= => enable_searchable_deprecation_msg, :deprecator => LaissCms::Deprecation

    def enable_searchable=(other)
      config.show_page_searchable_checkbox = other
    end
    deprecate enable_searchable: enable_searchable_deprecation_msg, deprecator: LaissCms::Deprecation

    delegate :preview_sources, to: :config
    delegate :preview_sources=, to: :config
    deprecate preview_sources: "Use `LaissCms.config.preview_sources` instead.", deprecator: LaissCms::Deprecation
    deprecate :preview_sources= => "Use `LaissCms.config.preview_sources=` instead.", :deprecator => LaissCms::Deprecation

    delegate :admin_js_imports, to: :config
    delegate :admin_js_imports=, to: :config
    deprecate admin_js_imports: "Use `LaissCms.config.admin_js_imports` instead", deprecator: LaissCms::Deprecation
    deprecate :admin_js_imports= => "Use `LaissCms.config.admin_js_imports=` instead", :deprecator => LaissCms::Deprecation

    delegate :admin_importmaps, to: :config
    deprecate admin_importmaps: "Use LaissCms.config.admin_importmaps instead", deprecator: LaissCms::Deprecation

    delegate :admin_stylesheets, to: :config
    deprecate admin_stylesheets: "Use LaissCms.config.admin_stylesheets instead", deprecator: LaissCms::Deprecation

    delegate :publish_targets, to: :config
    deprecate publish_targets: "Use LaissCms.config.publish_targets instead", deprecator: LaissCms::Deprecation

    delegate :link_dialog_tabs, to: :config
    deprecate link_dialog_tabs: "Use LaissCms.config.link_dialog_tabs instead", deprecator: LaissCms::Deprecation
  end
end

# Instantiate the global LaissCms namespace
require "laiss_cms"

# Require globally used external libraries
require "acts_as_list"
require "action_view/dependency_tracker"
require "active_model_serializers"
require "active_storage/engine"
require "awesome_nested_set"
require "cancan"
require "gutentag"
require "kaminari"
require "ransack"
require "simple_form"
require "turbo-rails"
require "userstamp"
require "view_component"

# Require globally used LaissCms mixins
require_relative "laiss_cms/auth_accessors"
require_relative "laiss_cms/cache_digests/template_tracker"
require_relative "laiss_cms/deprecation"
require_relative "laiss_cms/error_tracking"
require_relative "laiss_cms/errors"
require_relative "laiss_cms/forms/builder"
require_relative "laiss_cms/i18n"
require_relative "laiss_cms/logger"
require_relative "laiss_cms/modules"
require_relative "laiss_cms/on_page_layout"
require_relative "laiss_cms/on_page_layout/callbacks_runner"
require_relative "laiss_cms/paths"
require_relative "laiss_cms/tinymce"
require_relative "laiss_cms/version"

# Finally require LaissCms itself
require_relative "laiss_cms/engine"
