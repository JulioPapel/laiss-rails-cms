# frozen_string_literal: true

module LaissCms
  module TestSupport
    def self.factories_path
      ::LaissCms::Engine.root.join("lib", "laiss_cms", "test_support", "factories")
    end
  end
end

require_relative "test_support/viewport_screenshots"
