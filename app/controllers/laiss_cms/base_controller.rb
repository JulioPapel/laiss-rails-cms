# frozen_string_literal: true

# This is the main LaissCms controller all other controllers inherit from.
#
module LaissCms
  class BaseController < ApplicationController
    include LaissCms::ConfigurationMethods
    include LaissCms::AbilityHelper
    include LaissCms::ControllerActions
    include LaissCms::Modules

    protect_from_forgery

    before_action :mailer_set_url_options
    before_action :set_locale

    helper "laiss_cms/admin/form"

    rescue_from CanCan::AccessDenied do |exception|
      permission_denied(exception)
    end

    private

    # Sets +I18n.locale+ to current LaissCms language.
    #
    def set_locale
      return unless Current.language

      ::I18n.locale = Current.language&.locale
    end

    def not_found_error!(msg = "Not found \"#{request.fullpath}\"")
      raise ActionController::RoutingError, msg
    end

    # Store current request path into session,
    # so we can later redirect to it.
    def store_location
      session[:redirect_path] = request.path
    end

    def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end

    protected

    def permission_denied(exception = nil)
      if exception
        Logger.debug <<-WARN.strip_heredoc
          /!\\ Failed to permit #{exception.action} on #{exception.subject.inspect} for:
          #{current_laiss_cms_user.inspect}
        WARN
      end
      if current_laiss_cms_user
        handle_redirect_for_user
      else
        handle_redirect_for_guest
      end
    end

    def handle_redirect_for_user
      if api_request?
        return render json: {message: LaissCms.t("You are not authorized")}, status: :forbidden
      end

      flash[:warning] = LaissCms.t("You are not authorized")
      if can?(:index, :laiss_cms_admin_dashboard)
        redirect_or_render_notice
      else
        redirect_to LaissCms.config.unauthorized_path
      end
    end

    def redirect_or_render_notice
      if turbo_frame_request?
        render "403", status: 403
      else
        redirect_to(laiss_cms.admin_dashboard_path)
      end
    end

    def handle_redirect_for_guest
      flash[:info] = LaissCms.t("Please log in")
      if api_request?
        render json: {
          message: LaissCms.t("Please log in"),
          redirect_url: LaissCms.config.login_path
        }, status: :unauthorized
      elsif turbo_frame_request?
        # Redirecting would be followed inside the frame and render the login
        # page in the dialog. Turbo runs a stream action from any response,
        # whatever status or Accept header, so it can break out of the frame.
        render turbo_stream: helpers.turbo_stream_action_tag(
          :dialog_visit, url: LaissCms.config.login_path
        ), status: :unauthorized
      else
        store_location
        redirect_to LaissCms.config.login_path
      end
    end

    # Requests from our own admin JavaScript, that expect a machine readable
    # response instead of a page to render.
    def api_request?
      request.format.json? || request.xhr?
    end

    # Logs the current exception to the error log.
    def exception_logger(error)
      Logger.error("\n#{error.class} #{error.message} in #{error.backtrace.first}")
      Logger.error(error.backtrace[1..50].each { |line|
        line.gsub(/#{Rails.root}/, "")
      }.join("\n"))
    end
  end
end
