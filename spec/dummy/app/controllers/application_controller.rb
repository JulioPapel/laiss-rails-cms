# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # When loaded, the laiss-cms-devise engine handles authentication and
  # provides its own +current_user+ helper, so we must not shadow it.
  unless defined?(LaissCms::Devise::Engine)
    def current_user
      return if Rails.env.test?

      @_dummy_user ||= DummyUser.find_or_create_by(email: "dummy@laiss_cms.com")
    end
  end
end
