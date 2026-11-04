# frozen_string_literal: true

require "laiss_cms/version"

module LaissCms
  module Admin
    class DashboardController < LaissCms::Admin::BaseController
      authorize_resource class: :laiss_cms_admin_dashboard

      def index
      end

      def info
        LaissCms::Deprecation.warn <<~WARN
          Requesting `admin/dashboard/info` is deprecated. Please render LaissCms::Admin::Dashboard::Widgets::SystemInfo instead.
        WARN
      end

      def license
        @license = LaissCms::Engine.root.join("LICENSE").read
      end
    end
  end
end
