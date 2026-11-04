# frozen_string_literal: true

require "laiss_cms/version"

module LaissCms
  module Admin
    class PasswordsController < ::Devise::PasswordsController
      include LaissCms::Admin::Locale
      include LaissCms::Admin::CspProtection

      helper "LaissCms::Admin::Base"

      layout LaissCms::Devise.config.layout

      private

      # Override for Devise method
      def new_session_path(resource_name)
        laiss_cms.admin_login_path
      end

      def admin_edit_password_url(_resource, options = {})
        laiss_cms.admin_edit_password_url(options)
      end

      def after_resetting_password_path_for(resource)
        if can? :index, :laiss_cms_admin_dashboard
          laiss_cms.admin_dashboard_path
        else
          laiss_cms.root_path
        end
      end
    end
  end
end
