# frozen_string_literal: true

module LaissCms
  module Admin
    # The Settings screen.
    #
    # Reads and writes real engine configuration. Every field is declared once
    # in LaissCms::Admin::Settings, which also says whether a change takes effect
    # at runtime or needs a restart. Read-only fields are rendered disabled with
    # an explanation rather than hidden, so the screen answers "where does this
    # come from?" instead of pretending the value does not exist.
    #
    # Persistence: a successful update writes the whole writable set to
    # LaissCms::Preference under the "settings" scope. On boot the engine applies
    # that snapshot onto the config it just loaded from YAML, so values survive a
    # restart.
    class SettingsController < BaseController
      authorize_resource class: :laiss_cms_admin_settings

      def show
        build_form
      end

      def update
        submitted = params.fetch(:settings, {}).permit!.to_h
        @errors = {}

        LaissCms::Admin::Settings.writable.each do |field|
          next unless submitted.key?(field.key)

          ok, message = LaissCms::Admin::Settings.write(field, submitted[field.key])
          @errors[field.key] = message unless ok
        end

        if @errors.any?
          @sections = LaissCms::Admin::Settings::SECTIONS
          @values = submitted
          @read_only = read_only_values
          return render :show, status: :unprocessable_entity
        end

        persist!

        redirect_to laiss_cms.admin_settings_path, notice: LaissCms.t("settings.saved")
      end

      private

      def build_form
        @sections = LaissCms::Admin::Settings::SECTIONS
        @values = LaissCms::Admin::Settings.writable.to_h do |field|
          [field.key, LaissCms::Admin::Settings.read(field)]
        end
        @read_only = read_only_values
        @errors = {}
      end

      def read_only_values
        LaissCms::Admin::Settings::FIELDS.select(&:restart?).to_h do |field|
          [field.key, LaissCms::Admin::Settings.read(field)]
        end
      end

      # Stores what is currently in memory, not what was submitted: if a field
      # was coerced (a checkbox to a boolean) the persisted snapshot matches
      # reality rather than the form.
      def persist!
        snapshot = LaissCms::Admin::Settings.writable.to_h do |field|
          [field.key, LaissCms::Admin::Settings.read(field)]
        end

        LaissCms::Preference.set(
          LaissCms::Preference::SETTINGS,
          "config",
          LaissCms::Admin::Settings.snapshot(snapshot)
        )
      end
    end
  end
end
