require "laiss_cms/devise/configuration"
require "laiss_cms/devise/engine"

module LaissCms
  module Devise
    extend self

    def deprecator
      ActiveSupport::Deprecation.new("9.0", "LaissCms::Devise")
    end

    delegate :layout=, to: :config
    deprecate "layout=": "Use `LaissCms::Devise.config.layout=` instead.",
      deprecator: LaissCms::Devise.deprecator

    delegate :layout, to: :config
    deprecate layout: "Use `LaissCms::Devise.config.layout` instead.",
      deprecator: LaissCms::Devise.deprecator

    def config
      @config ||= LaissCms::Devise::Configuration.new
    end

    def configure(&blk)
      yield config
    end
  end

  extend self

  deprecate devise_modules: "LaissCms::Devise.config.devise_modules", deprecator: LaissCms::Devise.deprecator
  delegate :devise_modules, to: "LaissCms::Devise.config"
end
