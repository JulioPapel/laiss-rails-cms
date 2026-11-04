# frozen_string_literal: true

require "laiss_cms/configuration/base_option"

module LaissCms
  class Configuration
    class NumberOption < BaseOption
      def self.value_class
        Numeric
      end
    end
  end
end
