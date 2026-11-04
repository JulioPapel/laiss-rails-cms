# frozen_string_literal: true

require "rails"

module LaissCms
  module Generators
    class ViewsGenerator < ::Rails::Generators::Base
      LAISS_CMS_VIEWS = %w[breadcrumb language_links messages_mailer]

      desc "Generates LaissCms views for #{LAISS_CMS_VIEWS.to_sentence}."

      class_option :only,
        type: :array,
        default: nil,
        desc: "List of views to copy. Available views are #{LAISS_CMS_VIEWS.to_sentence}."

      class_option :except,
        type: :array,
        default: nil,
        desc: "List of views not to copy. Available views are #{LAISS_CMS_VIEWS.to_sentence}."

      source_root File.expand_path("../../../../../app/views/laiss_cms", __dir__)

      def copy_laiss_cms_views
        views_to_copy.each do |dir|
          directory dir, Rails.root.join("app/views/laiss_cms", dir)
        end
      end

      private

      def views_to_copy
        if @options["except"]
          LAISS_CMS_VIEWS - @options["except"]
        elsif @options["only"]
          LAISS_CMS_VIEWS.select { |v| @options["only"].include?(v) }
        else
          LAISS_CMS_VIEWS
        end
      end
    end
  end
end
