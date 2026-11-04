# frozen_string_literal: true

require "laiss_cms/shell"
require "thor"

module LaissCms
  class Upgrader
    include LaissCms::Shell
    include Thor::Base
    include Thor::Actions

    Dir["#{File.dirname(__FILE__)}/upgrader/*.rb"].sort.each { require(_1) }

    VERSION_MODULE_MAP = {
      "8.0" => "LaissCms::Upgrader::EightZero",
      "8.1" => "LaissCms::Upgrader::EightOne",
      "8.4" => "LaissCms::Upgrader::EightFour"
    }

    source_root LaissCms::Engine.root.join("lib/generators/laiss_cms/install")

    # Returns a memoized upgrader instance for the given version.
    # This ensures todos are accumulated across rake tasks.
    def self.[](version)
      @instances ||= {}
      @instances[version.to_s] ||= new(version)
    end

    def initialize(version)
      super()
      self.class.include VERSION_MODULE_MAP[version.to_s].constantize
    end

    def update_config
      desc "Copy configuration file."
      @default_config = LaissCms::Configurations::Main.new(
        storage_adapter: "dragonfly"
      )
      template("templates/laiss_cms.rb.tt", "config/initializers/laiss_cms.rb")
    end

    def run_migrations
      ActiveRecord::Migration.check_all_pending!
    rescue ActiveRecord::PendingMigrationError
      desc "Pending Database migrations."
      if yes?("Run database migrations now? (y/N)")
        log "Migrating Database..."
        Rake::Task["db:migrate"].invoke
      else
        log "Don't forget to run database migrations later with rake `db:migrate`.", :skip
      end
    end
  end
end
