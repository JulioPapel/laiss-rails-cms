# frozen_string_literal: true

module LaissCms
  module Admin
    # Persists a user's explicit light/dark choice.
    #
    # Deliberately its own small controller rather than an action on Settings:
    # every signed-in user may set their own theme, while changing engine
    # settings requires :manage. Sharing one controller would force the theme
    # toggle to demand a permission the toggle has no business demanding.
    #
    # The choice is stored per user, so it follows the account rather than the
    # browser. `system` clears the row, which returns the user to following the
    # OS on the next request.
    class ThemeController < BaseController
      # The constants live on the helper that resolves the theme, so the writer
      # and the reader cannot disagree about the allowed values.
      include LaissCms::Admin::ThemePreferenceHelper

      skip_authorization_check

      def update
        choice = params[:theme].to_s

        unless (ThemePreferenceHelper::THEMES + [ThemePreferenceHelper::SYSTEM]).include?(choice)
          return head :unprocessable_entity
        end

        LaissCms::Preference.set(
          LaissCms::Preference::THEME,
          "mode",
          choice == ThemePreferenceHelper::SYSTEM ? nil : choice,
          owner: current_laiss_cms_user
        )

        respond_to do |format|
          format.turbo_stream { head :no_content }
          format.json { render json: {theme: choice} }
          format.html { redirect_back fallback_location: admin_path }
        end
      end
    end
  end
end
