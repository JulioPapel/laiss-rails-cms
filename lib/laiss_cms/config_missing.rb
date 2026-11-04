# frozen_string_literal: true

module LaissCms
  module ConfigMissing
    def const_missing(missing_const_name)
      if missing_const_name == :Config
        LaissCms::Deprecation.warn("LaissCms::Config is deprecated. Use LaissCms.config instead.")
        LaissCms.config
      else
        super
      end
    end
  end
end
