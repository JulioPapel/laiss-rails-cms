module LaissCms
  module Devise
    module Generators
      class InstallGenerator < Rails::Generators::Base
        desc "Installs LaissCms Devise based authentication into your app."
        source_root File.expand_path("templates", File.dirname(__FILE__))

        def copy_devise_config
          template "devise.rb.tt", "config/initializers/devise.rb"
        end

        # Adds the devise routes the admin sign-in depends on.
        #
        # Without this the host app has a LaissCms::User model, the migrations and
        # the initializer, but no /admin/login route: LaissCms then raises
        # NoCurrentUserFoundError on every admin request because `current_user`
        # is never defined. The installer used to stop after copying the
        # initializer, which left a freshly installed site with an admin that
        # could not be signed into at all.
        #
        # The path mirrors what the engine's own admin expects and what the
        # reference demo app uses.
        def add_devise_routes
          return if File.read("config/routes.rb").include?("devise_for")

          route <<~RUBY
            devise_for :users,
              class_name: "LaissCms::User",
              path: "#{LaissCms.admin_path}",
              path_names: {sign_in: "login", sign_out: "logout", sign_up: "signup"},
              controllers: {sessions: "laiss_cms/admin/user_sessions", passwords: "laiss_cms/admin/passwords"}
          RUBY
        end

        # Copies this engine's migrations into the host application.
        #
        # Two things had to be established by measurement, not assumption:
        #
        #  1. `rake laiss_cms_devise:install:migrations` does not exist. Rails
        #     only defines that per-engine task for a MOUNTED engine, and this one
        #     is not mounted, so the old call aborted the installer with
        #     "Don't know how to build task".
        #
        #  2. The generic `railties:install:migrations FROM=laiss_cms_devise`
        #     silently copies nothing. It filters on `engine_name`, and this
        #     engine registers as `devise_engine` (Rails derives it from the
        #     `LaissCms::Devise::Engine` constant chain, not from the
        #     `engine_name` call), so the filter matches no engine. Verified:
        #     the task ran, reported success, and copied 0 files.
        #
        # So the source is addressed by PATH, which cannot drift from the name.
        # `bundle info` gives the installed gem directory.
        def add_migrations
          gem_path = `bundle info laiss-cms-devise --path`.strip
          source = File.join(gem_path, "db", "migrate")

          if gem_path.blank? || !File.directory?(source)
            say_status :error, "Could not locate laiss-cms-devise migrations at #{source}", :red
            return
          end

          Dir[File.join(source, "*.rb")].sort.each do |migration|
            copy_file migration, File.join("db/migrate", "#{File.basename(migration, ".rb")}.laiss_cms_devise.rb")
          end
        end

        def run_migrations
          run "bundle exec rake db:migrate"
        end
      end
    end
  end
end
