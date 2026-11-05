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

    initializer "laiss_cms.propshaft" do |app|
      if defined?(::Propshaft)
        if app.config.assets.server
          # Monkey-patch Propshaft::Asset to enable access
          # of TinyMCE assets without a hash digest.
          require_relative "propshaft/tinymce_asset"
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
          app.config.assets.paths += admin_import.source_paths.to_a
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

    config.after_initialize do
      if LaissCms.config.user_class
        ActiveSupport.on_load(:active_record) do
          LaissCms.config.user_class.model_stamper
          LaissCms.config.user_class.stampable(stamper_class_name: LaissCms.config.user_class_name)
        end
      end
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
