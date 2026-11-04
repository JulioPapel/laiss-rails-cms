# frozen_string_literal: true

require "laiss_cms/configuration/base_option"

module LaissCms
  class Configuration
    class ConfigurationOption < BaseOption
      def self.value_class
        Hash
      end

      attr_reader :config_class

      def initialize(value:, name:, config_class:, **args)
        @name = name
        @config_class = config_class
        validate(value)
        @value = if value.is_a?(config_class)
          value
        else
          config_class.new(value)
        end
      end

      def validate(value)
        return true if value.is_a?(config_class)
        super
      end

      def allowed_classes
        super + [config_class]
      end
    end
  end
end
