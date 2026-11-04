# frozen_string_literal: true

module LaissCms
  module Admin
    # Turbo Frame id wrapping admin dialog content. A form inside submits into
    # this frame, so its request carries the id and the server can tell a dialog
    # submission apart from the same form rendered on its own page.
    DIALOG_FRAME_ID = "laiss_cms_dialog_frame"

    class BaseController < LaissCms::BaseController
      include Userstamp
      include Locale
      include Timezone
      include CspProtection

      before_action :load_locked_pages

      check_authorization

      rescue_from Exception do |exception|
        if exception.is_a? CanCan::AccessDenied
          permission_denied(exception)
        elsif raise_exception?
          raise
        else
          exception_handler(exception)
        end
      end

      layout :set_layout

      def leave
        authorize! :leave, :laiss_cms_admin
        render template: "/laiss_cms/admin/leave", layout: !turbo_frame_request?
      end

      private

      # Controllers of the host application can inherit from this class, and
      # their views would not be ours to make assumptions about.
      def apply_content_security_policy? = controller_path.start_with?("laiss_cms/")

      def safe_redirect_path(path = params[:redirect_to], fallback: admin_path)
        if is_safe_redirect_path?(path)
          path
        elsif is_safe_redirect_path?(fallback)
          fallback
        else
          admin_path
        end
      end

      def is_safe_redirect_path?(path)
        mount_path = laiss_cms.root_path
        path.to_s.match? %r{^#{mount_path}#{LaissCms.admin_path}/}
      end

      def relative_referer_path(referer = request.referer)
        return unless referer

        URI(referer).path
      end

      # Disable layout rendering for Turbo Frame requests.
      #
      # Content requested by the dialog's Turbo Frame is wrapped in that frame,
      # so Turbo can render it. Only the dialog's own request carries this
      # frame id, so the same action rendered as a full page stays unwrapped.
      def set_layout
        if turbo_frame_request_id == DIALOG_FRAME_ID
          "laiss_cms/admin/dialog"
        elsif turbo_frame_request?
          false
        else
          "laiss_cms/admin"
        end
      end

      # Handles exceptions
      def exception_handler(error)
        exception_logger(error)
        show_error_notice(error)
        notify_error_tracker(error)
      end

      # Displays an error notice in the LaissCms backend.
      def show_error_notice(error)
        @error = error
        # truncate the message, because very long error messages (i.e from mysql2) causes cookie overflow errors
        @notice = error.message[0..255]
        if request.format.json?
          render json: {message: @notice}, status: 500
        else
          @trace = error.backtrace[0..50]
          render "500", status: 500
        end
      end

      def set_stamper
        if LaissCms.config.user_class.respond_to?(:stamper=)
          LaissCms.config.user_class.stamper = current_laiss_cms_user
        end
      end

      def reset_stamper
        if LaissCms.config.user_class.respond_to?(:reset_stamper)
          LaissCms.config.user_class.reset_stamper
        end
      end

      # Displays errors in a #errors div if any errors are present on the object.
      # Or redirects to the given redirect url.
      #
      # @param object [ActiveRecord::Base]
      # @param redirect_url [String]
      # @param flash_notice [String]
      #
      def render_errors_or_redirect(object, redirect_url, flash_notice)
        if object.errors.empty?
          flash[:notice] = LaissCms.t(flash_notice)
          do_redirect_to redirect_url
        else
          render action: ((params[:action] == "update") ? "edit" : "new"),
            status: 422
        end
      end

      # Does redirects for html, turbo_stream and js requests
      #
      # Makes sure that the redirect path is safe.
      #
      def do_redirect_to(url_or_path)
        redirect_path = safe_redirect_path(url_or_path)
        # A dialog form submits into the dialog frame, so a redirect would be
        # followed inside it and render the target page within the dialog. Let
        # the dialog close itself and visit the destination instead.
        if turbo_frame_request_id == DIALOG_FRAME_ID
          return render(turbo_stream: helpers.turbo_stream_action_tag(
            :dialog_visit, url: redirect_path
          ))
        end
        respond_to do |format|
          format.turbo_stream do
            redirect_to(redirect_path, allow_other_host: false, status: :see_other)
          end
          format.html do
            redirect_to(redirect_path, allow_other_host: false, status: :see_other)
          end
        end
      end

      # This method decides if we want to raise an exception or not.
      #
      # I.e. in test environment.
      #
      def raise_exception?
        Rails.env.test? || is_page_preview?
      end

      # Are we currently in the page edit mode page preview.
      def is_page_preview?
        controller_path == "laiss_cms/admin/pages" && action_name == "show"
      end

      def load_locked_pages
        @locked_pages ||= current_laiss_cms_user&.locked_pages
      end

      # Returns the current site for admin controllers.
      #
      def current_laiss_cms_site
        @current_laiss_cms_site ||= begin
          site_id = params[:site_id] || session[:laiss_cms_site_id]
          site = Site.find_by(id: site_id) || super
          session[:laiss_cms_site_id] = site&.id
          site
        end
      end

      def notify_error_tracker(exception)
        if ::LaissCms::ErrorTracking.notification_handler.respond_to?(:call)
          ::LaissCms::ErrorTracking.notification_handler.call(exception)
        else
          Logger.warn("To use the LaissCms::ErrorTracking.notification_handler, it must respond to #call.")
        end
      end
    end
  end
end
