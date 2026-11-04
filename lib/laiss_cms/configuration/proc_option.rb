# frozen_string_literal: true

require "laiss_cms/configuration/base_option"

module LaissCms
  class Configuration
    class ProcOption < BaseOption
      def self.value_class
        Proc
      end
    end
  end
end
