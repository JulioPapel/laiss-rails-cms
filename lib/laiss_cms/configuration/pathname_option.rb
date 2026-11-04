# frozen_string_literal: true

require "laiss_cms/configuration/base_option"
module LaissCms
  class Configuration
    class PathnameOption < BaseOption
      def self.value_class
        Pathname
      end
    end
  end
end
