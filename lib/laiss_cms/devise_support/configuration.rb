require "laiss_cms/configuration"

module LaissCms
  module Devise
    class Configuration < LaissCms::Configuration
      # Layout for LaissCms Devise controllers
      # Default is +laiss_cms/admin+
      option :layout, :string, default: "laiss_cms/admin"

      # Devise modules included in +LaissCms::User+ model
      #
      # === Default modules
      #
      #     [
      #       :database_authenticatable,
      #       :trackable,
      #       :validatable,
      #       :timeoutable,
      #       :recoverable,
      #       :rememberable
      #     ]
      #
      # If you want to add additional modules into the LaissCms user class append
      # them to this collection in an initializer in your app.
      #
      # === Example
      #
      #     # config/initializers/laiss_cms.rb
      #     LaissCms::Devise.config.devise_modules << :registerable
      #
      # If your app uses an old encryption that needs the +devise-encryptable+ gem
      # you also need to load the devise module.
      #
      #     LaissCms::Devise.config.devise_modules << :encryptable
      #
      option :devise_modules, :collection, collection_class: Set, item_type: :symbol, default: [
        :database_authenticatable,
        :trackable,
        :validatable,
        :timeoutable,
        :recoverable,
        :rememberable
      ]

      # Require the acting user to confirm their own password before LaissCms
      # roles are granted or changed
      #
      # Creating a user with roles and changing the roles of an existing user
      # both ask for the password of the user performing the change. Every
      # other user attribute can be edited with a valid session alone.
      #
      # === Example
      #
      #     # config/initializers/laiss_cms.rb
      #     LaissCms::Devise.config.require_password_for_role_change = false
      #
      option :require_password_for_role_change, :boolean, default: true

      # LaissCms roles that may only be granted or revoked with a password
      #
      # Only +admin+ can manage users, so granting any other role does not
      # cross a trust boundary and never asks for a password.
      #
      # === Example
      #
      #     # config/initializers/laiss_cms.rb
      #     LaissCms::Devise.config.privileged_user_roles << "editor"
      #
      option :privileged_user_roles, :collection, item_type: :string, default: %w[admin]
    end
  end
end
