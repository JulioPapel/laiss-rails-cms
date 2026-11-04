# frozen_string_literal: true

module LaissCms
  class << self
    # LaissCms shortcut translation method
    #
    # Instead of having to call:
    #
    #     LaissCms::I18n.translate(:hello)
    #
    # You can use this shortcut method:
    #
    #     LaissCms.t(:hello)
    #
    def t(msg, **kwargs)
      LaissCms::I18n.translate(msg, **kwargs)
    end

    # LaissCms shortcut localization method
    #
    # Instead of having to call:
    #
    #     LaissCms::I18n.localize(datetime)
    #
    # You can use this shortcut method:
    #
    #     LaissCms.l(datetime)
    #
    def l(datetime, **kwargs)
      LaissCms::I18n.localize(datetime, **kwargs)
    end
  end

  module I18n
    LOCALE_FILE_PATTERN = /laiss_cms\.(\S{2,5})\.yml/

    class << self
      # LaissCms translation methods
      #
      # Instead of having to translate strings and defining a default value:
      #
      #     LaissCms::I18n.translate("Hello World!", default: 'Hello World!')
      #
      # We define this method to define the value only once:
      #
      #     LaissCms::I18n.translate("Hello World!")
      #
      # Note that interpolation still works:
      #
      #     LaissCms::I18n.translate("Hello %{world}!", world: @world)
      #
      # === Notes
      #
      # All translations are scoped into the +laiss_cms+ namespace.
      # Even scopes are scoped into the +laiss_cms+ namespace.
      #
      # So a call for LaissCms::translate('hello', scope: 'world') has to be translated like this:
      #
      #   de:
      #     laiss_cms:
      #       world:
      #         hello: Hallo
      #
      def translate(msg, **options)
        humanize_default_string!(msg, options)
        scope = laiss_cms_scoped_scope(options)
        ::I18n.t(msg, **options.merge(scope: scope))
      end

      # Returns a localized time string for the given time and format.
      #
      # @param datetime [Time|Date|nil]
      # @param format [Symbol] (:"laiss_cms.default")
      #
      # @return [String|nil]
      def localize(datetime, format: :"laiss_cms.default")
        return nil if datetime.nil?

        ::I18n.l(datetime, format:)
      end

      def available_locales
        Rails.application.config.i18n.available_locales || begin
          @@available_locales ||= nil
          @@available_locales || translation_files.collect { |f|
            f.match(LOCALE_FILE_PATTERN)[1].to_sym
          }.uniq.sort
        end
      end

      def available_locales=(locales)
        @@available_locales = Array(locales).map(&:to_sym)
        @@available_locales = nil if @@available_locales.empty?
      end

      private

      def translation_files
        ::I18n.load_path.select { |path| path.match(LOCALE_FILE_PATTERN) }
      end

      def humanize_default_string!(msg, options)
        return if options[:default].present?

        options[:default] = msg.is_a?(Symbol) ? msg.to_s.humanize : msg
      end

      def laiss_cms_scoped_scope(options)
        default_scope = ["laiss_cms"]
        case options[:scope]
        when Array
          default_scope + options[:scope]
        when String
          default_scope << options[:scope]
        when Symbol
          if options[:scope] != :laiss_cms
            default_scope << options[:scope]
          end
        else
          default_scope
        end
      end
    end
  end
end
