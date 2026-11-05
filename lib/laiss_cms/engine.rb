# frozen_string_literal: true

module LaissCms
  class Engine < Rails::Engine
    isolate_namespace LaissCms
    engine_name "laiss_cms"
    config.mount_at = "/"

    initializer "laiss_cms.lookup_context" do
      LaissCms::LOOKUP_CONTEXT = ActionView::LookupContext.new(Rails.root.join("app", "views", "laiss_cms"))
    end

    initializer "laiss_cms.dependency_tracker" do
      [:erb, :slim, :haml].each do |handler|
        ActionView::DependencyTracker.register_tracker(handler, CacheDigests::TemplateTracker)
      end
    end

    initializer "laiss_cms.assets" do |app|
      if defined?(::Sprockets)
        require_relative "sprockets/skip_builds_compression"
        require_relative "../non_stupid_digest_assets"
        NonStupidDigestAssets.whitelist += [/^tinymce\//]
        app.config.assets.precompile << "laiss_cms_manifest.js"
      end
    end

    initializer "laiss_cms.admin_stylesheets" do |app|
      if defined?(::Sprockets)
        LaissCms.config.admin_stylesheets.each do |stylesheet|
          app.config.assets.precompile << stylesheet
        end
      end
    end

    # The sign-in screens load a small stylesheet of their own. It used to be
    # precompiled by the separate devise engine; folded in, it is listed here and
    # only when that integration is active, so apps without it do not precompile an
    # asset they never reference.
    initializer "laiss_cms.devise_assets" do |app|
      next unless LaissCms.const_defined?(:Devise) && LaissCms::Devise.available?
      next unless app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)

      app.config.assets.precompile << "laiss_cms_devise.css"
    end

    initializer "laiss_cms.propshaft" do |app|
      if defined?(::Propshaft)
        if app.config.assets.server
          # Monkey-patch Propshaft::Asset to enable access
          # of TinyMCE assets without a hash digest.
          require_relative "propshaft/tinymce_asset"
        end
      end
    end

    # Translations for every locale except English live in
    # config/locales/extra/ and need NO initializer.
    #
    # Rails globs `config/locales/**/*.yml` for every engine root, so placing the
    # files at LaissCms::Engine.root/config/locales/extra/ is enough: verified 10
    # files on I18n.load_path from a plain boot, with nothing in this file doing
    # it. An explicit initializer was tried first and registered `de` twice,
    # because Rails had already globbed it — a duplicate that I18n silently
    # merges, so the only symptom was a doubled entry in the load path.
    #
    # The vendor JS for flatpickr and select2 still needs adding, because asset
    # paths are not globbed from engines the way locale files are.
    #
    # Guarded: `--minimal` apps (and any app without sprockets or propshaft) have
    # no `config.assets` at all, and this initializer must not be what stops them
    # booting. Verified against a scratch app with neither.
    initializer "laiss_cms.locale_assets" do |app|
      next unless app.config.respond_to?(:assets) && app.config.assets.respond_to?(:paths)

      asset_path = root.join("vendor/assets/javascripts").to_s
      paths = app.config.assets.paths.map(&:to_s)
      app.config.assets.paths << asset_path unless paths.include?(asset_path)
    end

    # Pin the per-locale JS for flatpickr and select2. These are fetched by name
    # at runtime, so the importmap cannot discover them.
    initializer "laiss_cms.locale_importmap_pins" do |app|
      engine_root = root

      app.config.to_prepare do
        locales = Array(app.config.i18n.available_locales).map(&:to_s).reject { |l| l == "en" }

        locales.each do |locale|
          flatpickr = engine_root.join("vendor/assets/javascripts/flatpickr", "#{locale}.js")
          if File.exist?(flatpickr)
            LaissCms.importmap.pin "flatpickr/#{locale}.js", to: "flatpickr/#{locale}.js"
          end

          select2 = engine_root.join("vendor/assets/javascripts/select2", "select2_locale_#{locale}.js")
          if File.exist?(select2)
            LaissCms.importmap.pin "select2/#{locale}.js", to: "select2_locale_#{locale}.js"
          end
        end
      end
    end

    initializer "laiss_cms.admin_importmap" do
      LaissCms.config.admin_importmaps.add(
        importmap_path: root.join("config/importmap.rb"),
        source_paths: [
          root.join("app/javascript"),
          root.join("vendor/javascript")
        ],
        name: "laiss_cms_admin"
      )
    end

    initializer "laiss_cms.importmap" do |app|
      app.config.to_prepare do
        watch_paths = []

        LaissCms.config.admin_importmaps.each do |admin_import|
          LaissCms.importmap.draw admin_import.importmap_path
          watch_paths += admin_import.source_paths.to_a
          # Read inside to_prepare, not captured outside it: the configuration is
          # rebuilt between the initializer and this block, so a reference taken
          # earlier points at an array nobody reads, which silently emptied the
          # rendered importmap. Guarded because a `--minimal` app has no
          # `config.assets` at all.
          if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:paths)
            admin_import.source_paths.to_a.each do |source_path|
              app.config.assets.paths << source_path unless app.config.assets.paths.include?(source_path)
            end
          end
          if admin_import[:name] != "laiss_cms_admin"
            LaissCms.config.admin_js_imports.add(admin_import.name)
          end
        end

        if app.config.importmap.sweep_cache
          # The importmap pins resolve to the bundled files in app/assets/builds,
          # so the cache must be swept when those are rebuilt. Without this the
          # cached importmap keeps emitting the previous digest after a rebuild
          # and the asset 404s until the server is restarted.
          watch_paths << LaissCms::Engine.root.join("app/assets/builds")
          LaissCms.importmap.cache_sweeper(watches: watch_paths)
          ActiveSupport.on_load(:action_controller_base) do
            before_action { LaissCms.importmap.cache_sweeper.execute_if_updated }
          end
        end
      end
    end

    # All the initialization that needs to be re-triggered during reloads
    config.to_prepare do
      # Definition files
      elements_reloader = Rails.application.config.file_watcher.new([ElementDefinition.definitions_file_path]) do
        Logger.info "Reloading Element Definitions."
        ElementDefinition.reset!
      end
      page_layouts_reloader = Rails.application.config.file_watcher.new([PageDefinition.layouts_file_path]) do
        Logger.info "Reloading Page Layouts."
        PageDefinition.reset!
      end
      [elements_reloader, page_layouts_reloader].each do |reloader|
        Rails.application.reloaders << reloader
        Rails.application.reloader.to_run do
          reloader.execute_if_updated
        end
      end

      # The storage adapter for Pictures and Attachments
      #
      # Chose between 'active_storage' (default) or 'dragonfly' (legacy)
      #
      # Can be set via 'LAISS_CMS_STORAGE_ADAPTER' env var.
      LaissCms.storage_adapter = LaissCms::StorageAdapter.new(
        ENV.fetch("LAISS_CMS_STORAGE_ADAPTER", LaissCms.config.storage_adapter)
      )

      # Gutentag downcases all tags before save
      # and Gutentag validations are not case sensitive.
      # But we support having tags with uppercase characters.
      Gutentag.normaliser = ->(value) { value.to_s }
      Gutentag.tag_validations = LaissCms::TagValidations
    end

    # Custom Ransack sort arrows
    initializer "laiss_cms.ransack" do
      Ransack.configure do |config|
        config.custom_arrows = {
          up_arrow: '<laiss-cms-icon name="arrow-up" size="1x"></laiss-cms-icon>',
          down_arrow: '<laiss-cms-icon name="arrow-down" size="1x"></laiss-cms-icon>'
        }
      end

      ActiveSupport.on_load(:active_storage_blob) do
        ActiveStorage::Blob.define_singleton_method(:ransackable_attributes) do |_auth_object|
          %w[filename]
        end

        ActiveStorage::Blob.define_singleton_method(:ransackable_associations) do |_auth_object|
          %w[]
        end
      end
    end

    # Load LaissCms configuration from YAML files
    # in config/laiss_cms/config.yml and config/laiss_cms/#{Rails.env}.config.yml
    # if they exist.
    # This has to be done before any app initializers are loaded, so that
    # the configuration is available in all initializers.
    initializer "laiss_cms.config_yml", before: :load_config_initializers do |app|
      config_directory = Rails.root.join("config", "laiss_cms")
      main_config = config_directory.join("config.yml")
      env_specific_config = config_directory.join("#{Rails.env}.config.yml")
      if File.exist?(main_config)
        LaissCms.config.set_from_yaml(main_config)
      end
      if File.exist?(env_specific_config)
        LaissCms.config.set_from_yaml(env_specific_config)
      end
    end

    # Apply values saved from the admin's Settings screen.
    #
    # Runs AFTER the YAML above, so an edit made in the browser wins over the
    # file default. It runs after :load_config_initializers too, which means a
    # host app's own `LaissCms.configure do ... end` block still wins over both:
    # code beats a saved value, and a saved value beats a file. That ordering is
    # deliberate — the repo is the source of truth, the database is the override.
    #
    # `config.to_prepare` so it re-applies on every code reload in development
    # without needing a process restart, and so a test that truncates the
    # preferences table sees the YAML defaults again.
    initializer "laiss_cms.saved_settings", after: :load_config_initializers do |app|
      app.config.to_prepare do
        next unless defined?(LaissCms::Preference) && LaissCms::Preference.available?

        stored = LaissCms::Preference.get(
          LaissCms::Preference::SETTINGS, "config", fallback: nil
        )
        next if stored.blank?

        LaissCms::Admin::Settings.apply_snapshot(
          LaissCms.config,
          LaissCms::Admin::Settings.restore(stored)
        )
      end
    end

    # The registration that used to live in the devise engine's own
    # config/initializers. Guarded, because none of it is meaningful without the
    # authentication screens the ability and the navigation entry point at.
    initializer "laiss_cms.devise_admin" do |app|
      next unless LaissCms.const_defined?(:Devise) && LaissCms::Devise.available?

      app.config.to_prepare do
        LaissCms.config.abilities.add("LaissCms::DeviseAbility")

        LaissCms::Modules.register_module({
          name: "users",
          engine_name: "laiss_cms",
          position: 4.1,
          navigation: {
            name: "modules.users",
            controller: "/laiss_cms/admin/users",
            action: "index",
            icon: "group"
          }
        })

        LaissCms.config.signup_path = "/admin/signup"
        LaissCms.config.login_path = "/admin/login"
        LaissCms.config.logout_path = "/admin/logout"
        LaissCms.config.logout_method = ::Devise.sign_out_via.to_s
        LaissCms.config.edit_user_path = "/admin/users/:id/edit"
        LaissCms.config.admin_users_path = "/admin/users"
      end
    end

    config.after_initialize do
      if LaissCms.config.user_class
        ActiveSupport.on_load(:active_record) do
          LaissCms.config.user_class.model_stamper
          LaissCms.config.user_class.stampable(stamper_class_name: LaissCms.config.user_class_name)
        end
      end
    end

    # The admin renders its stylesheets and JavaScript through the asset pipeline:
    # the layout calls asset_path, stylesheet_link_tag and
    # javascript_importmap_tags, and importmap-rails reads config.assets. Without
    # a pipeline every admin page raises
    #   NoMethodError: undefined method 'assets'
    # from inside a template, which names neither this engine nor the fix.
    #
    # Fail at boot instead, with the requirement and the exact line to add. The
    # admin routes are always drawn and cannot be switched off, so an app without
    # a pipeline has no working surface at all — 500ing on the first admin request
    # is strictly worse than saying so up front.
    #
    # Not a gem dependency: either propshaft or sprockets satisfies it, and adding
    # both would force a choice on apps that already have one.
    initializer "laiss_cms.require_asset_pipeline" do |app|
      # `config.assets` is added by propshaft's and sprockets' railties, so its
      # absence means neither is installed.
      next if app.config.respond_to?(:assets)

      raise LaissCms::AssetPipelineMissing.new
    end

    initializer "laiss_cms.webp-mime_type" do |app|
      webp = "image/webp"
      svg = "image/svg+xml"

      # Dragonfly uses Rack to read the mime type and guess what
      # Rack 3.0 has this included, but Rails 8 still allows Rack 2.2
      unless Rack::Mime::MIME_TYPES[".webp"]
        Rack::Mime::MIME_TYPES[".webp"] = webp
      end

      if app.config.active_storage
        # Serve SVGs with their real image/svg+xml content type so they render
        # in <img> tags. We deliberately do NOT add svg to
        # +content_types_allowed_inline+: an SVG opened as a top-level document
        # executes its embedded scripts, so it must be served with an
        # attachment (download) disposition rather than inline. <img> ignores
        # Content-Disposition, so image display is unaffected.
        if app.config.active_storage.content_types_to_serve_as_binary.include? svg
          app.config.active_storage.content_types_to_serve_as_binary.delete(svg)
        end
      end
    end
  end
end
