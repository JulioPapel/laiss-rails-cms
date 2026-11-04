# frozen_string_literal: true

module LaissCms
  module Configurations
    class DefaultSite < LaissCms::Configuration
      option :name, :string, default: "Default Site"
      option :host, :string, default: "*"
    end
  end
end
