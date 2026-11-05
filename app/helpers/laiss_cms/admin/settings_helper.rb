# frozen_string_literal: true

module LaissCms
  module Admin
    module SettingsHelper
      # Option pairs for a select field. Labels are translated through the same
      # keys the rest of the admin uses, with the raw value as a fallback so an
      # untranslated language code still renders sensibly.
      def select_choices(field)
        values = field.options || LaissCms::Admin::Settings.select_options(field)

        values.map do |value|
          label = case field.key
                  when "admin_theme"
                    LaissCms.t(value.capitalize, default: value.humanize)
                  when "default_language.code"
                    LaissCms::Language.find_by(language_code: value)&.name.presence || value
                  else
                    value.to_s.humanize
                  end
          [label, value]
        end
      end
    end
  end
end
