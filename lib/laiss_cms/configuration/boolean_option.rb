# frozen_string_literal: true

require "laiss_cms/configuration/base_option"

module LaissCms
  class Configuration
    class BooleanOption < BaseOption
      def allowed_classes
        [TrueClass, FalseClass]
      end
    end
  end
end
