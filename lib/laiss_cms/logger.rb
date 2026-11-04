# frozen_string_literal: true

module LaissCms
  module Logger
    # Logs a debug message to the Rails standard logger
    def self.debug(message)
      Rails.logger.tagged("laiss_cms") do
        Rails.logger.debug(message)
      end
      nil
    end

    # Logs a error message to the Rails standard logger
    def self.error(message)
      Rails.logger.tagged("laiss_cms") do
        Rails.logger.error("ERROR: #{message}")
      end
      nil
    end

    # Logs a info message to the Rails standard logger
    def self.info(message)
      Rails.logger.tagged("laiss_cms") do
        Rails.logger.info(message)
      end
      nil
    end

    # Logs a warning message to the Rails standard logger
    def self.warn(message, caller_string = nil)
      if caller_string
        LaissCms::Deprecation.warn("LaissCms::Logger.warn second argument is deprecated and will be removed in LaissCms 9.0")
      end
      Rails.logger.tagged("laiss_cms") do
        Rails.logger.warn("WARNING: #{message}")
      end
      nil
    end

    def log_warning(message)
      LaissCms::Logger.warn(message)
    end
    deprecate log_warning: "LaissCms::Logger.warn", deprecator: LaissCms::Deprecation
  end
end
