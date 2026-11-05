module LaissCms
  # Authorization rules for the Devise backed user.
  #
  # Named at the LaissCms level rather than under LaissCms::Devise because a
  # directory named `devise` under an autoload root claims the LaissCms::Devise
  # constant for Zeitwerk, which shadowed the module lib/laiss_cms/devise.rb
  # defines and made `LaissCms::Devise.available?` explode.
  class DeviseAbility
    include CanCan::Ability

    def initialize(user)
      @user = user

      can :signup, LaissCms::User
      can :create, LaissCms::User if LaissCms::User.count == 0

      if member? || author? || editor?
        can [:show, :update], LaissCms::User, id: user.id
      end

      if editor? || admin?
        can :index, :laiss_cms_admin_users
        can :read, LaissCms::User
      end

      if admin?
        can :manage, LaissCms::User
      end
    end

    private

    def member?
      @user.try(:has_laiss_cms_role?, :member)
    end

    def author?
      @user.try(:has_laiss_cms_role?, :author)
    end

    def editor?
      @user.try(:has_laiss_cms_role?, :editor)
    end

    def admin?
      @user.try(:has_laiss_cms_role?, :admin)
    end
  end
end
