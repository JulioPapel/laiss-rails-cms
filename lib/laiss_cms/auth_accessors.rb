# frozen_string_literal: true

module LaissCms
  class << self
    delegate :user_class_primary_key, to: :config
    deprecate user_class_primary_key: "Use `LaissCms.config.user_class_primary_key instead", deprecator: LaissCms::Deprecation

    delegate :user_class_primary_key=, to: :config
    deprecate :user_class_primary_key= => "Use `LaissCms.config.user_class_primary_key instead", :deprecator => LaissCms::Deprecation

    delegate :current_user_method, to: :config
    deprecate current_user_method: "Use `LaissCms.config.current_user_method instead", deprecator: LaissCms::Deprecation

    delegate :current_user_method=, to: :config
    deprecate :current_user_method= => "Use `LaissCms.config.current_user_method instead", :deprecator => LaissCms::Deprecation

    delegate :signup_path, to: :config
    deprecate signup_path: "Use `LaissCms.config.signup_path instead", deprecator: LaissCms::Deprecation

    delegate :signup_path=, to: :config
    deprecate :signup_path= => "Use `LaissCms.config.signup_path instead", :deprecator => LaissCms::Deprecation

    delegate :login_path, to: :config
    deprecate login_path: "Use `LaissCms.config.login_path instead", deprecator: LaissCms::Deprecation

    delegate :login_path=, to: :config
    deprecate :login_path= => "Use `LaissCms.config.login_path instead", :deprecator => LaissCms::Deprecation

    delegate :logout_path, to: :config
    deprecate logout_path: "Use `LaissCms.config.logout_path instead", deprecator: LaissCms::Deprecation

    delegate :logout_path=, to: :config
    deprecate :logout_path= => "Use `LaissCms.config.logout_path instead", :deprecator => LaissCms::Deprecation

    delegate :logout_method, to: :config
    deprecate logout_method: "Use `LaissCms.config.logout_method instead", deprecator: LaissCms::Deprecation

    delegate :logout_method=, to: :config
    deprecate :logout_method= => "Use `LaissCms.config.logout_method instead", :deprecator => LaissCms::Deprecation

    delegate :unauthorized_path, to: :config
    deprecate unauthorized_path: "Use `LaissCms.config.unauthorized_path instead", deprecator: LaissCms::Deprecation

    delegate :unauthorized_path=, to: :config
    deprecate :unauthorized_path= => "Use `LaissCms.config.unauthorized_path instead", :deprecator => LaissCms::Deprecation

    delegate :user_class, to: :config
    deprecate user_class: "Use `LaissCms.config.user_class instead", deprecator: LaissCms::Deprecation

    delegate :user_class_name, to: :config
    deprecate user_class_name: "Use `LaissCms.config.user_class_name instead", deprecator: LaissCms::Deprecation

    def user_class_name=(klass_name)
      config.user_class = klass_name
    end
    deprecate :user_class_name= => "Use `LaissCms.config.user_class instead", :deprecator => LaissCms::Deprecation

    def register_ability(klass)
      config.abilities.add(klass.name)
    end
    deprecate register_ability: 'Use `LaissCms.config.abilities.add("MyClass")` instead', deprecator: LaissCms::Deprecation

    def registered_abilities
      config.abilities
    end
    deprecate registered_abilities: "Use `LaissCms.config.abilities` instead", deprecator: LaissCms::Deprecation
  end
end
