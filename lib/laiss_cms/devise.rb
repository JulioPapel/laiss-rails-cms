require "laiss_cms/devise_support/configuration"

module LaissCms
  # Devise based authentication, folded into the engine but kept optional.
  #
  # `devise` is deliberately NOT a runtime dependency of laiss_cms. A host app
  # that supplies its own user model and sign-in must boot without it, and this
  # repository's core specs run against a plain DummyUser stub for that reason.
  #
  # ACTIVATION IS AN EXPLICIT REQUIRE
  #
  # Nothing happens until the host app asks for this file:
  #
  #   # config/application.rb, after `require "laiss_cms"`
  #   require "laiss_cms/devise"
  #
  # Requiring it loads the devise gem and the engine that carries the model,
  # controllers, mailer and patch. Not requiring it means no Devise constant, no
  # LaissCms::User, and no sign-in routes — but a working CMS.
  #
  # This has to be a plain require rather than an initializer: the engine class
  # must exist before Rails collects engines at boot, and the routes file has to
  # know whether the integration is present by the time it is evaluated.
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

    # True once laiss_cms/devise has been required successfully. Read by the
    # engine's routes to decide whether to draw the sign-in, password and user
    # routes, and by the initializer that registers the ability and the admin
    # navigation entry.
    def available?
      @available == true
    end

    # Loads the devise gem and then the engine that integrates it. Returns false
    # instead of raising when the gem is missing, so a host app that requires this
    # file by mistake gets a clear warning rather than a boot failure.
    def activate!
      return true if available?

      require "devise"
      require "laiss_cms/devise_support/railtie"
      @available = true
    rescue LoadError => error
      LaissCms::Logger.warn(
        "LaissCms: authentication is not active because #{error.message}. " \
        "Add `gem \"devise\"` to your Gemfile to use the admin sign-in."
      )
      false
    end
  end

  extend self

  deprecate devise_modules: "LaissCms::Devise.config.devise_modules", deprecator: LaissCms::Devise.deprecator
  delegate :devise_modules, to: "LaissCms::Devise.config"
end

LaissCms::Devise.activate!
