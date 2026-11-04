# frozen_string_literal: true

module LaissCms
  module ErrorTracking
    class BaseHandler
      def self.call(exception)
        # implement your own notification method
      end
    end

    mattr_accessor :notification_handler
  end
end

require "laiss_cms/error_tracking/error_logger"
LaissCms::ErrorTracking.notification_handler = LaissCms::ErrorTracking::ErrorLogger
