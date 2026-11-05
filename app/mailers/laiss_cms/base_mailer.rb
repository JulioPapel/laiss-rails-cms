# frozen_string_literal: true

module LaissCms
  begin
    base_class = Object.const_get("::ApplicationMailer")
  rescue NameError
    # Fully qualified: inside `module LaissCms` a bare ActionMailer resolves to
    # LaissCms::ActionMailer and raises, which only showed up in an app that has no
    # ApplicationMailer to find first.
    base_class = ::ActionMailer::Base
  end

  # The +BaseMailer+ is the class all LaissCms mailers inherit from.
  #
  # Itself inherits from +ApplicationMailer+ when it is defined, or
  # as a fallback from +ActionMailer::Base+.
  #
  # +ApplicationMailer+ is the Rails standard for registering helpers and
  # setting the default layout. It is only generated though, when you
  # +rails generate+ a mailer.
  #
  class BaseMailer < base_class; end
end
