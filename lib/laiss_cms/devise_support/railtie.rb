module LaissCms
  module Devise
    # Loaded only when the host app requires "laiss_cms/devise", so nothing here
    # runs in an app that brings its own authentication.
    #
    # WHY THE DEVISE CODE IS NOT UNDER app/
    #
    # `LaissCms::User` and the three controllers that inherit from Devise classes
    # cannot live in the engine's app/ tree. Rails eager loads that tree in
    # production, so a host app without the `devise` gem failed at boot with
    # "uninitialized constant Devise" — measured on a scratch app, not assumed.
    #
    # They live in lib/laiss_cms/devise_app/laiss_cms instead, which is added as an
    # autoload root only when this railtie loads. Being a real autoload root (and
    # not a bare `require`) is what lets Zeitwerk resolve the concerns the model
    # includes, such as LaissCms::Taggable, from the main engine's app/models.
    #
    # A Railtie rather than an Engine: it used to be an engine with its own root,
    # routes and autoload paths, and an engine whose root is now the laiss_cms gem
    # root loads config/routes.rb a second time ("Invalid route name, already in
    # use: 'root'"). Everything else — views, locales, routes — lives in the main
    # engine.
    class Railtie < ::Rails::Railtie
      initializer "laiss_cms_devise.autoload", before: :set_autoload_paths do |app|
        app.config.autoload_paths << File.expand_path("../devise_app", __dir__)
        app.config.eager_load_paths << File.expand_path("../devise_app", __dir__)
      end

      # After the autoload root above, so LaissCms::User can actually be resolved
      # when the string is constantized.
      initializer "laiss_cms_devise.user_class", after: :set_autoload_paths do
        LaissCms.config.user_class = "LaissCms::User"
      end

      # Request-time stamping on the base controller. Kept as a patch because the
      # behaviour belongs to the user model, not to the controller.
      #
      # to_prepare, because LaissCms::BaseController is autoloaded and is not
      # defined yet during the initializers. The prepend is guarded so a code
      # reload does not stack the module on the class again.
      initializer "laiss_cms_devise.base_controller_patch" do |app|
        app.config.to_prepare do
          # The patch file prepends itself on load, and guards against being
          # prepended twice, so requiring it is all that is needed.
          require File.expand_path("patches/base_controller_patch", __dir__)
        rescue LoadError, NameError
          # A host app that replaces LaissCms::BaseController does not need it, and
          # must not fail to boot because of it.
          nil
        end
      end
    end
  end
end
