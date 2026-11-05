# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # When loaded, the devise integration handles authentication and provides its
  # own +current_user+ helper, so we must not shadow it. That integration is now
  # part of laiss_cms rather than a separate engine, so the test is whether it is
  # active, not whether an engine constant exists.
  unless LaissCms.const_defined?(:Devise) && LaissCms::Devise.available?
    def current_user
      return if Rails.env.test?

      @_dummy_user ||= DummyUser.find_or_create_by(email: "dummy@laiss_cms.com")
    end
  end
end
