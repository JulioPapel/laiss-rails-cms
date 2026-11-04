# frozen_string_literal: true

require "laiss_cms/version"

module LaissCms
  module Admin
    class UserSessionsController < ::Devise::SessionsController
      include LaissCms::Admin::Locale
      include LaissCms::Admin::CspProtection

      protect_from_forgery prepend: true

      before_action :check_user_count, only: :new

      helper "LaissCms::Admin::Base"

      layout LaissCms::Devise.config.layout

      def create
        authenticate_user!

        if user_signed_in?
          redirect_path = if session[:redirect_path].blank?
            admin_dashboard_path
          else
            # We have to strip double slashes from beginning of path, because of strange rails/rack bug.
            session[:redirect_path].gsub(/\A\/{2,}/, "/")
          end
          redirect_to redirect_path,
            notice: t(:signed_in, scope: "devise.sessions")
        else
          super
        end
      end

      def destroy
        current_laiss_cms_user.try(:unlock_pages!)
        cookies.clear
        session.clear
        super
      end

      private

      def check_user_count
        if User.count == 0
          redirect_to admin_signup_path
        end
      end

      # Overwriting the default of Devise
      def after_sign_out_path_for(resource_or_scope)
        if request.referer.blank? || request.referer.to_s.include?("admin")
          root_path
        else
          request.referer
        end
      end
    end
  end
end
