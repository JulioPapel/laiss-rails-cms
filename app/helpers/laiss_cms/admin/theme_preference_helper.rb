# frozen_string_literal: true

module LaissCms
  module Admin
    # Resolves which theme a page should render in.
    #
    # Deliberately a VIEW HELPER rather than a controller concern. The admin
    # layout is shared by controllers that inherit from very different bases —
    # the admin BaseController, but also Devise's sessions and passwords
    # controllers, which do not. A concern on BaseController leaves the login
    # screen unable to resolve a theme and the layout raises. A helper is
    # available anywhere the layout renders, including a host app's own
    # controller that opts into the admin layout.
    #
    # Three inputs, in priority order:
    #
    #   1. THE USER'S EXPLICIT CHOICE. Persisted in LaissCms::Preference so it
    #      survives a logout and lands on the very first byte of the next page,
    #      which is what avoids a flash of the wrong theme.
    #   2. THE HOST'S CONFIGURED DEFAULT. `LaissCms.config.admin_theme` still
    #      works and still wins over the OS, so an existing deployment that
    #      pins a theme keeps that behaviour.
    #   3. THE OPERATING SYSTEM. No attribute is rendered at all and the CSS
    #      media queries in theme.scss decide. This is the default.
    #
    # The resolved value is written onto <html data-theme> by the layout, so the
    # server and the CSS agree before any JavaScript runs. That is the whole
    # anti-flash story: no client-side script has to run first.
    module ThemePreferenceHelper
      THEMES = %w[light dark].freeze
      # The stored value meaning "no explicit choice, follow the OS".
      SYSTEM = "system"

      # The value to render into data-theme. nil means "no attribute", i.e.
      # follow the OS.
      def laiss_cms_theme
        return @laiss_cms_theme if defined?(@laiss_cms_theme)

        choice = laiss_cms_theme_choice
        @laiss_cms_theme = (choice == SYSTEM) ? nil : choice
      end

      # The stored preference, whether it came from the user, the host config,
      # or the fallback. Always one of THEMES + SYSTEM.
      def laiss_cms_theme_choice
        return @laiss_cms_theme_choice if defined?(@laiss_cms_theme_choice)

        stored = LaissCms::Preference.get(
          LaissCms::Preference::THEME, "mode", owner: theme_preference_owner
        )

        @laiss_cms_theme_choice =
          if THEMES.include?(stored)
            stored
          else
            configured = LaissCms.config.admin_theme.to_s
            THEMES.include?(configured) ? configured : SYSTEM
          end
      end

      private

      # Signed out, there is no per-user row to read; the host default and the
      # OS still apply, which is what makes the login screen match the admin.
      def theme_preference_owner
        respond_to?(:current_laiss_cms_user) ? current_laiss_cms_user : nil
      end
    end
  end
end
