# frozen_string_literal: true

module LaissCms
  module Admin
    # The catalogue behind the Settings screen.
    #
    # The screen is data-driven from this file rather than hand-written markup,
    # so the form, the validation and the honesty labels cannot drift apart.
    #
    # Each entry declares:
    #
    #   key        the config option name, exactly as it appears in
    #              config/laiss_cms/config.yml, so an operator can find the
    #              line the screen is writing.
    #   type       :string, :integer, :boolean, :select
    #   effects    :runtime  — the value is read on each request, so writing it
    #                          to LaissCms.config takes effect on the next page
    #                          load and is persisted for the next boot.
    #              :restart  — the value is consumed during boot (asset
    #                          paths, middleware, a resolved class), so it is
    #                          shown but not editable. Editing it would be a lie.
    #
    # Nothing here invents a setting. Every key below exists on
    # LaissCms::Configurations::Main and is read somewhere in the engine.
    module Settings
      Field = Struct.new(
        :key, :section, :type, :effects, :default, :min, :max, :options,
        keyword_init: true
      ) do
        def runtime? = effects == :runtime
        def restart? = effects == :restart
      end

      # Order here is the order on the screen.
      FIELDS = [
        Field.new(
          key: "default_site.name", section: :site, type: :string, effects: :runtime,
          default: "Default Site"
        ),
        Field.new(
          key: "default_language.code", section: :site, type: :select, effects: :runtime,
          default: "en"
        ),
        Field.new(
          key: "admin_theme", section: :appearance, type: :select, effects: :runtime,
          default: "system", options: %w[system light dark]
        ),
        Field.new(
          key: "items_per_page", section: :behaviour, type: :integer, effects: :runtime,
          default: 15, min: 1, max: 200
        ),
        Field.new(
          key: "uploader.upload_limit", section: :uploads, type: :integer, effects: :runtime,
          default: 50, min: 1, max: 100
        ),
        Field.new(
          key: "uploader.file_size_limit", section: :uploads, type: :integer, effects: :runtime,
          default: 100, min: 1, max: 2000
        ),
        Field.new(
          key: "cache_pages", section: :behaviour, type: :boolean, effects: :runtime,
          default: true
        ),
        Field.new(
          key: "show_page_searchable_checkbox", section: :behaviour, type: :boolean,
          effects: :runtime, default: false
        ),
        Field.new(
          key: "auto_logout_time", section: :behaviour, type: :integer, effects: :runtime,
          default: 30, min: 1, max: 1440
        ),

        # Read-only. These are resolved while the application boots, so a write
        # here would do nothing until the process restarted. Shown so the screen
        # answers "where does this come from?", labelled so nobody expects an
        # edit to work.
        Field.new(key: "default_language.name", section: :read_only, type: :string, effects: :restart),
        Field.new(key: "default_language.page_layout", section: :read_only, type: :string, effects: :restart),
        Field.new(key: "default_site.host", section: :read_only, type: :string, effects: :restart),
        Field.new(key: "storage_adapter", section: :read_only, type: :string, effects: :restart),
        Field.new(key: "image_output_format", section: :read_only, type: :string, effects: :restart)
      ].freeze

      SECTIONS = %i[site appearance uploads behaviour read_only].freeze

      class << self
        def fields_for(section)
          FIELDS.select { |field| field.section == section }
        end

        def find(key)
          FIELDS.find { |field| field.key == key }
        end

        def writable
          FIELDS.select(&:runtime?)
        end

        # Reads the current value from config without mutating anything.
        def read(field, config = LaissCms.config)
          value = dig(config, field.key)
          return field.default if value.nil?

          value
        end

        # Applies a submitted value to the in-memory config, coercing and
        # validating. Returns [ok, error].
        #
        # The in-memory write is what makes a change take effect on the next
        # request; `persist!` is what makes it survive a restart.
        #
        # `check_options` is false when replaying a saved snapshot. Two reasons:
        # a select's choices can come from the database (the language list), and
        # the boot initializer that replays a snapshot must never touch the
        # database — it runs before one may be available. A saved value was
        # already validated when it was written, so re-checking it against a
        # DB-derived list buys nothing and costs a query at boot.
        def write(field, raw, config = LaissCms.config, check_options: true)
          return [false, "not writable"] unless field.runtime?

          case field.type
          when :boolean
            value = ActiveModel::Type::Boolean.new.cast(raw)
            assign(config, field.key, value)
          when :integer
            unless raw.to_s.match?(/\A-?\d+\z/)
              return [false, LaissCms.t("settings.errors.not_a_number")]
            end
            value = raw.to_i
            if (field.min && value < field.min) || (field.max && value > field.max)
              return [false, LaissCms.t("settings.errors.out_of_range", min: field.min, max: field.max)]
            end
            assign(config, field.key, value)
          when :select
            if check_options
              allowed = field.options || select_options(field)
              unless allowed.include?(raw.to_s)
                return [false, LaissCms.t("settings.errors.not_allowed")]
              end
            end
            assign(config, field.key, raw.to_s)
          else
            value = raw.to_s.strip
            return [false, LaissCms.t("settings.errors.blank")] if value.blank?

            assign(config, field.key, value)
          end

          [true, nil]
        end

        def select_options(field)
          case field.key
          when "default_language.code"
            # `language_code` is the column; `code` is the model's reader.
            LaissCms::Language.distinct.pluck(:language_code).compact.sort.presence || %w[en]
          else
            []
          end
        end

        # Serialises the whole catalogue for persistence.
        def snapshot(values)
          values.transform_keys(&:to_s).to_json
        end

        def restore(json)
          JSON.parse(json.to_s)
        rescue JSON::ParserError
          {}
        end

        # Applies a persisted snapshot back onto config. Called at boot, after
        # the YAML has been loaded, so a saved value beats the file default and
        # still loses to an explicit environment override.
        #
        # Never raises and never queries: a corrupt or stale snapshot must not
        # be able to stop the application from booting.
        def apply_snapshot(config, snapshot)
          snapshot.each do |key, value|
            field = find(key)
            # A saved value for a key that no longer exists, or that is no
            # longer writable, is dropped rather than resurrected.
            next unless field&.runtime?

            write(field, value, config, check_options: false)
          end
        rescue => error
          LaissCms::Logger.warn(
            "LaissCms: could not apply saved settings: #{error.class}: #{error.message}"
          )
        end

        private

        def dig(config, key)
          *path, last = key.split(".")
          target = path.reduce(config) { |memo, part| memo&.public_send(part) }
          target&.public_send(last)
        end

        def assign(config, key, value)
          *path, last = key.split(".")
          target = path.reduce(config) { |memo, part| memo.public_send(part) }
          target.public_send(:"#{last}=", value)
        end
      end
    end
  end
end
