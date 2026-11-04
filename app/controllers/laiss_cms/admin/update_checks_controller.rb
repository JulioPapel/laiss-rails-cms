module LaissCms
  module Admin
    class UpdateChecksController < LaissCms::Admin::BaseController
      def show
        authorize! :update_check, :laiss_cms_admin_dashboard

        if update_check_result[:update_available]
          render json: {
            status: false,
            latest_version: update_check_result[:latest_version],
            message: LaissCms.t("Update available")
          }
        else
          render json: {
            status: true,
            latest_version: update_check_result[:latest_version],
            message: LaissCms.t("LaissCms is up to date")
          }
        end

        expires_in cache_duration, public: true
      rescue UpdateServiceUnavailable
        render json: {
          message: LaissCms.t("Update status unavailable")
        }, status: 503
      end

      private

      def update_check_result
        @_update_check_result ||= Rails.cache.fetch("laiss_cms_update_check", expires_in: cache_duration) do
          update_checker = LaissCms::UpdateChecker.new(origin: request.host)
          {
            update_available: update_checker.update_available?,
            latest_version: update_checker.latest_version.to_s
          }
        end
      end

      def cache_duration
        LaissCms.config.update_check_cache_duration.hours
      end
    end
  end
end
