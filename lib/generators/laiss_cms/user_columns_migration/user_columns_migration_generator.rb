# frozen_string_literal: true

require "rails/generators/active_record/migration"

module LaissCms
  module Generators
    class UserColumnsMigrationGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      desc "Generate migration for columns needed by LaissCms user class"

      class_option :table_name,
        type: :string,
        desc: "User class table name",
        default: LaissCms.config.user_class.table_name

      source_root File.expand_path("templates", File.dirname(__FILE__))

      def generate
        migration_template "migration.rb.tt", "db/migrate/add_laiss_cms_fields_to_#{table_name}_table.rb"
      end

      private

      def table_name
        options[:table_name] || LaissCms.config.user_class.table_name
      end
    end
  end
end
