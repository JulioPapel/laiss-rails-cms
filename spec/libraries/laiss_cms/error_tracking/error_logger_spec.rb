# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::ErrorTracking::ErrorLogger do
  describe ".call" do
    it "logs the exception into Rails logger with laiss_cms tag" do
      expect(::Rails.logger).to receive(:tagged).with("laiss_cms").and_yield
      expect(::Rails.logger).to receive(:error).with("RuntimeError: foo in /foo/bar.rb:1")
      error = RuntimeError.new("foo")
      error.set_backtrace(["/foo/bar.rb:1"])
      described_class.call(error)
    end
  end
end
