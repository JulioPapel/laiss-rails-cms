# frozen_string_literal: true

require "laiss_cms/upgrader"
require "laiss_cms/version"

namespace :laiss_cms do
  desc "Upgrades your app to LaissCMS v#{LaissCms::VERSION}."
  task upgrade: [
    "laiss_cms:upgrade:prepare",
    "laiss_cms:upgrade:8.0:run",
    "laiss_cms:upgrade:8.1:run",
    "laiss_cms:upgrade:8.4:run"
  ] do
    LaissCms::Upgrader["8.4"].run_migrations
    LaissCms::Upgrader["8.4"].display_todos
  end

  namespace :upgrade do
    desc "LaissCms Upgrader: Prepares the database and updates Alchemys configuration file."
    task prepare: [
      "laiss_cms:upgrade:database",
      "laiss_cms:upgrade:config"
    ]

    desc "LaissCms Upgrader: Prepares the database."
    task database: [
      "laiss_cms:install:migrations"
    ]

    desc "LaissCms Upgrader: Update configuration file."
    task config: [:environment] do
      LaissCms::Upgrader["8.0"].update_config
    end

    namespace "8.0" do
      task "run" => [
        "laiss_cms:upgrade:8.0:mention_laiss_cms_config_initializer"
      ]

      task :mention_laiss_cms_config_initializer do
        LaissCms::Upgrader["8.0"].mention_laiss_cms_config_initializer
      end
    end

    namespace "8.1" do
      task "run" => [
        "laiss_cms:upgrade:8.1:migrate_page_metadata"
      ]

      desc "Migrate page metadata to page versions"
      task migrate_page_metadata: [
        "laiss_cms:install:migrations",
        "environment"
      ] do
        LaissCms::Upgrader["8.1"].run_migrations
        LaissCms::Upgrader["8.1"].migrate_page_metadata
      end
    end

    namespace "8.4" do
      task "run" => [
        "laiss_cms:upgrade:8.4:add_dragonfly_gem",
        "laiss_cms:upgrade:8.4:upgrade_nested_elements_rendering",
        "laiss_cms:upgrade:8.4:notify_attachment_filetypes_default",
        "laiss_cms:upgrade:8.4:notify_admin_content_security_policy",
        "laiss_cms:upgrade:8.4:notify_picture_format_setting",
        "laiss_cms:upgrade:8.4:upgrade_menu_config"
      ]

      desc "Add dragonfly gem to the Gemfile if the app uses the dragonfly storage adapter"
      task add_dragonfly_gem: [:environment] do
        LaissCms::Upgrader["8.4"].add_dragonfly_gem
      end

      desc "Rewrite element partials to render nested elements through the block helper"
      task upgrade_nested_elements_rendering: [:environment] do
        LaissCms::Upgrader["8.4"].upgrade_nested_elements_rendering
      end

      desc "Notify about the new attachment upload allowlist default"
      task notify_attachment_filetypes_default: [:environment] do
        LaissCms::Upgrader["8.4"].notify_attachment_filetypes_default
      end

      desc "Notify about the new admin Content Security Policy"
      task notify_admin_content_security_policy: [:environment] do
        LaissCms::Upgrader["8.4"].notify_admin_content_security_policy
      end

      desc "Notify about the new format setting of picture ingredients"
      task notify_picture_format_setting: [:environment] do
        LaissCms::Upgrader["8.4"].notify_picture_format_setting
      end

      desc "Rewrite register_module calls to the new menu configuration"
      task upgrade_menu_config: [:environment] do
        LaissCms::Upgrader["8.4"].upgrade_menu_config
      end
    end
  end
end
