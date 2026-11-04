# frozen_string_literal: true

module LaissCms::AbilityHelper
  # Ensures usage of LaissCms's permissions class.
  #
  # == Register custom Abilities
  #
  # If your app has a CanCan Ability class with rules you want to be aviable in an LaissCms context
  # you need to register it. Or if you have an engine with it's own CanCan abilities you want to
  # add to LaissCms you must register them first.
  #
  #     LaissCms.register_ability MyCustom::Permisson
  #
  def current_ability
    @current_ability ||= begin
      laiss_cms_permissions = LaissCms::Permissions.new(current_laiss_cms_user)
      LaissCms.config.abilities.each do |klass|
        laiss_cms_permissions.merge(klass.new(current_laiss_cms_user))
      end
      laiss_cms_permissions
    end
  end
end
