# frozen_string_literal: true

module LaissCms
  module ControllerActions
    extend ActiveSupport::Concern

    included do
      before_action :set_current_laiss_cms_site
      before_action :set_laiss_cms_language
      before_action :set_current_laiss_cms_user

      helper "laiss_cms/pages"

      helper_method :current_laiss_cms_user,
        :laiss_cms_user_signed_in?,
        :current_laiss_cms_site,
        :current_server
    end

    private

    # Returns a host string with the domain the app is running on.
    def current_server
      "#{request.protocol}#{request.host_with_port}"
    end

    # The current authorized user.
    #
    # In order to have LaissCms's authorization work, you have to
    # provide a +current_user+ method in your app's ApplicationController,
    # that returns the current user. To change the method +current_laiss_cms_user+
    # will call, set +LaissCms.current_user_method+ to a different method name.
    #
    # If you don't have an App that can provide a +current_user+ object, the
    # engine's bundled Devise integration provides everything you need: add
    # `require "laiss_cms/devise"` to config/application.rb.
    #
    def current_laiss_cms_user
      current_user_method = LaissCms.config.current_user_method
      raise NoCurrentUserFoundError if !respond_to?(current_user_method, true)

      send current_user_method
    end

    # Returns true if a +current_laiss_cms_user+ is present
    #
    def laiss_cms_user_signed_in?
      current_laiss_cms_user.present?
    end

    # Returns the current site.
    #
    def current_laiss_cms_site
      @current_laiss_cms_site ||= Site.find_for_host(request.host)
    end

    # Sets the current site in a cvar so the Language model
    # can be scoped against it.
    #
    def set_current_laiss_cms_site
      Current.site = current_laiss_cms_site
    end

    # Stores the current user in +Current.user+ so models and services can
    # access the acting user without threading it through every call.
    #
    # Apps without a configured +current_user_method+ leave it +nil+ instead
    # of raising, so the public frontend keeps working without authentication.
    #
    def set_current_laiss_cms_user
      Current.user = current_laiss_cms_user
    rescue NoCurrentUserFoundError
      Current.user = nil
    end

    # Sets the current language for LaissCms.
    #
    def set_laiss_cms_language(lang = nil)
      @language = if lang
        lang.is_a?(Language) ? lang : load_laiss_cms_language_from_id_or_code(lang)
      else
        load_laiss_cms_language_from_params || Language.default
      end

      store_current_laiss_cms_language(@language)
    end

    def load_laiss_cms_language_from_params
      if params[:locale].present?
        Language.find_by_code(params[:locale]) ||
          raise(ActionController::RoutingError, "Language not found")
      end
    end

    def load_laiss_cms_language_from_id_or_code(id_or_code)
      Language.find_by(id: id_or_code) ||
        Language.find_by_code(id_or_code) ||
        Language.default
    end

    # Stores language in +Current.language+
    #
    def store_current_laiss_cms_language(language)
      if language&.id
        Current.language = language
      end
    end
  end
end
