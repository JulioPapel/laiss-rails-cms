module LaissCms
  module Devise
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc "Installs LaissCms Devise based authentication into your app."
        source_root File.expand_path("templates", File.dirname(__FILE__))

        def copy_devise_config
          template "devise.rb.tt", "config/initializers/devise.rb"
        end

        # The sign-in, password and user routes come from laiss_cms itself now, so
        # nothing is appended here. They are registered by the engine only when
        # `::Devise` is loaded, which is exactly when this generator is used.
        def check_devise_loaded
          return if defined?(::Devise)

          say_status :warning,
            "Devise is not loaded yet. Add `gem \"devise\"` to your Gemfile and run bundle install, then boot the app.",
            :yellow
        end

        # Copies the user migrations into the host application.
        #
        # They live inside this generator rather than in the engine's db/migrate
        # because devise is optional: an app that brings its own user model must
        # not get a laiss_cms_users table it never asked for. Copying is what
        # makes them run, and it keeps the namespaced `.laiss_cms_devise` suffix
        # that stops them colliding with a host app's own user migrations.
        def add_migrations
          Dir[File.expand_path("migrations/*.rb", __dir__)].sort.each do |migration|
            copy_file migration,
              File.join("db/migrate", "#{File.basename(migration, ".rb")}.laiss_cms_devise.rb")
          end
        end

        def run_migrations
          run "bundle exec rake db:migrate"
        end
      end
    end
  end
end
