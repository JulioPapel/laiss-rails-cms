# frozen_string_literal: true

module LaissCms
  module ErrorTracking
    class ErrorLogger < BaseHandler
      def self.call(exception)
        ::Rails.logger.tagged("laiss_cms") do
          ::Rails.logger.error("#{exception.class.name}: #{exception.message} in #{exception.backtrace.first}")
        end
      end
    end
  end
end
