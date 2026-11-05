# frozen_string_literal: true

require "devise/orm/active_record"
require "userstamp"

module LaissCms
  class User < ActiveRecord::Base
    PERMITTED_ATTRIBUTES = [
      :firstname,
      :lastname,
      :login,
      :email,
      :language,
      :password,
      :password_confirmation,
      :send_credentials,
      :tag_list,
      :timezone
    ]

    devise(*LaissCms::Devise.config.devise_modules)

    include LaissCms::Taggable
    include LaissCms::UserMethods

    attr_accessor :send_credentials

    has_many :folded_pages

    validates :login, uniqueness: {case_sensitive: false}, presence: :login_required?

    scope :admins, -> {
      LaissCms::Deprecation.warn("#{name}.admins is deprecated. Please use #{name}.laiss_cms_admins instead.")
      laiss_cms_admins
    }

    scope :logged_in, -> { where("last_request_at > ?", logged_in_timeout.seconds.ago) }
    scope :logged_out, -> { where("last_request_at is NULL or last_request_at <= ?", logged_in_timeout.seconds.ago) }

    ROLES = LaissCms.config.user_roles

    class << self
      def ransackable_attributes(_auth_object = nil)
        %w[
          email
          firstname
          lastname
          login
        ]
      end

      def ransortable_attributes(_auth_object = nil)
        %w[last_sign_in_at]
      end

      alias_method :searchable_laiss_cms_resource_attributes, :ransackable_attributes

      def ransackable_associations(_auth_object = nil)
        %w[
          taggings
          tags
        ]
      end

      deprecate human_rolename: :human_laiss_cms_rolename, deprecator: LaissCms::Deprecation
      alias_method :human_rolename, :human_laiss_cms_rolename

      def logged_in_timeout
        LaissCms.config.get(:auto_logout_time).minutes.to_i
      end
    end

    def role_symbols
      laiss_cms_roles.map(&:to_sym)
    end
    deprecate :role_symbols, deprecator: LaissCms::Deprecation

    def role
      laiss_cms_roles.first
    end
    deprecate :role, deprecator: LaissCms::Deprecation

    def add_role(role)
      self.laiss_cms_roles = laiss_cms_roles.push(role.to_s).uniq
    end
    deprecate add_role: :"laiss_cms_roles=", deprecator: LaissCms::Deprecation

    alias_method :is_admin?, :laiss_cms_admin?
    deprecate is_admin?: :laiss_cms_admin?, deprecator: LaissCms::Deprecation

    alias_method :has_role?, :has_laiss_cms_role?
    deprecate has_role?: :has_laiss_cms_role?, deprecator: LaissCms::Deprecation

    alias_method :human_roles_string, :human_laiss_cms_roles
    deprecate human_roles_string: :human_laiss_cms_roles, deprecator: LaissCms::Deprecation

    # Returns the firstname and lastname as a string
    #
    # If both are blank, returns the login
    #
    # @option options :flipped (false)
    #   Flip the firstname and lastname
    #
    def fullname(options = {})
      if lastname.blank? && firstname.blank?
        login
      else
        options = {flipped: false}.merge(options)
        fullname = options[:flipped] ? "#{lastname}, #{firstname}" : "#{firstname} #{lastname}"
        fullname.squeeze(" ").strip
      end
    end

    alias_method :name, :fullname
    alias_method :laiss_cms_display_name, :fullname

    def email_required?
      ::Devise.authentication_keys.include?(:email)
    end

    def login_required?
      ::Devise.authentication_keys.include?(:login)
    end

    # Returns true if the last request not longer ago then the logged_in_time_out
    def logged_in?
      raise "Can not determine the records login state because there is no last_request_at column" if !respond_to?(:last_request_at)
      !last_request_at.nil? && last_request_at > logged_in_timeout.seconds.ago
    end

    # Opposite of logged_in?
    def logged_out?
      !logged_in?
    end

    alias_method :pages_locked_by_me, :locked_pages
    deprecate pages_locked_by_me: :locked_pages, deprecator: LaissCms::Deprecation

    def store_request_time!
      update_column(:last_request_at, Time.now)
    end

    # Delivers a welcome mail depending from user's role.
    #
    def deliver_welcome_mail
      if has_laiss_cms_role?("author") || has_laiss_cms_role?("editor") || has_laiss_cms_role?("admin")
        Notifications.laiss_cms_user_created(self).deliver_later
      else
        Notifications.member_created(self).deliver_later
      end
    end

    private

    def logged_in_timeout
      self.class.logged_in_timeout
    end
  end
end
