module LaissCms
  module Admin
    class UsersController < ResourcesController
      before_action :set_roles, except: [:index, :destroy]

      load_and_authorize_resource class: LaissCms::User,
        only: [:edit, :update, :destroy]

      authorize_resource class: LaissCms::User,
        only: [:index, :new, :signup, :create]

      before_action :confirm_password_for_role_change, only: [:create, :update]

      helper_method :while_signup?, :can_update_role?, :password_confirmation_required?,
        :carried_over_user_params, :confirmed_laiss_cms_roles

      def index
        @query = User.ransack(params[:q])
        @query.sorts = "login asc" if @query.sorts.empty?
        @users = @query.result
          .page(params[:page] || 1)
          .per(items_per_page)
      end

      def new
        @user = User.new(send_credentials: true)
      end

      def signup
        if while_signup?
          new
        else
          flash[:warning] = LaissCms.t(:cannot_signup_more_then_once)
          redirect_to admin_dashboard_path
        end
      end

      def create
        @user = User.new(user_params)

        if while_signup?
          signup_admin_or_redirect
        else
          create_user_or_redirect
        end
      end

      def update
        # User is fetched via before filter
        if params[:user][:password].present?
          @user.update(user_params)
        else
          @user.update_without_password(user_params)
        end
        deliver_welcome_mail
        render_errors_or_redirect @user,
          admin_users_path,
          LaissCms.t("User updated", name: @user.name)
      end

      def destroy
        # User is fetched via before filter
        name = @user.name
        if @user.destroy
          flash[:notice] = LaissCms.t("User deleted", name: name)
        end
        do_redirect_to admin_users_path
      end

      private

      def confirm_password_for_role_change
        return unless role_change_requested?

        # Keeps the password field around if the save fails validation later on
        @password_confirmation_required = true
        # Captured before the submitted attributes are assigned, so that a
        # revoked role is still known
        @confirmed_laiss_cms_roles =
          privileged_roles(requested_laiss_cms_roles) | privileged_roles(persisted_laiss_cms_roles)
        current_password = params[:user][:current_password].to_s
        return if current_laiss_cms_user.valid_password?(current_password)

        @user ||= User.new
        @user.assign_attributes(user_params)
        @user.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        if user_password_required?
          render action: (@user.new_record? ? :new : :edit), status: :unprocessable_content
        else
          render :confirm_password, status: :unprocessable_content
        end
      end

      def role_change_requested?
        return false unless LaissCms::Devise.config.require_password_for_role_change
        return false if while_signup? || !can_update_role?
        # An absent key leaves the roles untouched, it does not revoke them
        return false unless params[:user].key?(:laiss_cms_roles)

        privileged_roles(requested_laiss_cms_roles) != privileged_roles(persisted_laiss_cms_roles)
      end

      def privileged_roles(roles)
        roles & LaissCms::Devise.config.privileged_user_roles.to_a
      end

      def requested_laiss_cms_roles
        User.new(laiss_cms_roles: params.dig(:user, :laiss_cms_roles)).laiss_cms_roles.sort
      end

      def persisted_laiss_cms_roles
        (@user || User.new).laiss_cms_roles.sort
      end

      def password_confirmation_required?
        !!@password_confirmation_required
      end

      # The confirmation form replaces the real one, so the submitted attributes
      # ride along in hidden fields. Passwords are deliberately left out: a
      # hidden field would expose them to the very script execution this
      # confirmation defends against.
      def carried_over_user_params
        user_params.except(:password, :password_confirmation)
      end

      def confirmed_laiss_cms_roles
        @confirmed_laiss_cms_roles.map { User.human_laiss_cms_rolename(_1) }.to_sentence
      end

      def user_password_required?
        @user.new_record? || params.dig(:user, :password).present?
      end

      def set_roles
        if can_update_role?
          @user_roles = User::ROLES.map do |role|
            [User.human_laiss_cms_rolename(role), role]
          end
        end
      end

      def user_params
        params.require(:user).permit(*secure_attributes)
      end

      def secure_attributes
        if can_update_role?
          User::PERMITTED_ATTRIBUTES + [{laiss_cms_roles: []}]
        else
          User::PERMITTED_ATTRIBUTES
        end
      end

      def while_signup?
        @_while_signup ||= User.count == 0
      end

      def signup_admin_or_redirect
        @user.laiss_cms_roles = %w[admin]
        if @user.save
          flash[:notice] = LaissCms.t("Successfully signup admin user")
          sign_in :user, @user
          deliver_welcome_mail
          redirect_to admin_pages_path
        else
          render :signup, status: :unprocessable_content
        end
      end

      def create_user_or_redirect
        @user.save
        deliver_welcome_mail
        render_errors_or_redirect @user,
          admin_users_path,
          LaissCms.t("User created", name: @user.name)
      end

      def can_update_role?
        can? :update_role, LaissCms::User
      end

      def deliver_welcome_mail
        if @user.valid? && @user.send_credentials == "1"
          @user.deliver_welcome_mail
        end
      end
    end
  end
end
