# frozen_string_literal: true

module LaissCms
  # ## LaissCms's permissions
  #
  # These are CanCan abilities, but to prevent any naming collusions we named it permissions.
  #
  # LaissCms user rules are modules that can be included in your app's/engine's Ability class.
  #
  # ### Example:
  #
  #     # app/models/ability.rb
  #     class Ability
  #       include CanCan::Ability
  #       include LaissCms::Permissions::EditorUser
  #
  #       def initialize(user)
  #         return if user.nil?
  #         @user ||= user
  #         if @user.has_role?(:demo)
  #           laiss_cms_editor_rules # laiss_cms editor roles
  #           # your own rules
  #         end
  #       end
  #     end
  #
  class Permissions
    include CanCan::Ability

    def initialize(user)
      set_action_aliases
      @user ||= user
      @user ? user_role_rules : laiss_cms_guest_user_rules
    end

    module GuestUser
      def laiss_cms_guest_user_rules
        can([:show, :download], LaissCms::Attachment) { |a| !a.restricted? }

        can :read, LaissCms::Element, LaissCms::Element.published.not_restricted do |e|
          e.public? && !e.restricted?
        end

        can :read, LaissCms::Page, LaissCms::Page.published.not_restricted.from_current_site do |p|
          p.public? && !p.restricted? && p.site == LaissCms::Current.site
        end

        can :read, LaissCms::Node, LaissCms::Node.available_to_guests do |node|
          node.language.public? && node.language.site_id == LaissCms::Current.site&.id &&
            (node.page.nil? || (node.page.public? && !node.page.restricted?))
        end
      end
    end

    # == Member rules
    #
    # Includes guest users rules
    #
    module MemberUser
      include LaissCms::Permissions::GuestUser

      def laiss_cms_member_rules
        laiss_cms_guest_user_rules

        # Resources
        can [:show, :download], LaissCms::Attachment

        can :read, LaissCms::Element, LaissCms::Element.published do |e|
          e.public?
        end

        can :read, LaissCms::Page,
          LaissCms::Page.published.from_current_site.readable_by(@user) do |p|
          p.public? && p.site == LaissCms::Current.site && p.readable_by?(@user)
        end

        can :read, LaissCms::Node, LaissCms::Node.available_to(@user) do |node|
          node.language.public? && node.language.site_id == LaissCms::Current.site&.id &&
            (node.page.nil? || (node.page.public? && node.page.readable_by?(@user)))
        end
      end
    end

    # == Author rules
    #
    # Includes member users rules
    #
    module AuthorUser
      include LaissCms::Permissions::MemberUser

      def laiss_cms_author_rules
        laiss_cms_member_rules

        # Navigation
        can :index, [
          :laiss_cms_admin_attachments,
          :laiss_cms_admin_dashboard,
          :laiss_cms_admin_layoutpages,
          :laiss_cms_admin_nodes,
          :laiss_cms_admin_pages,
          :laiss_cms_admin_pictures,
          :laiss_cms_admin_tags,
          :laiss_cms_admin_users
        ]

        # Controller actions
        can :leave, :laiss_cms_admin
        can [:info, :license, :help, :show], :laiss_cms_admin_dashboard
        can :manage, :laiss_cms_admin_clipboard
        can :update, :laiss_cms_admin_layoutpages
        can :tree, :laiss_cms_admin_pages

        # Resources
        can [:read, :download], LaissCms::Attachment
        can :manage, LaissCms::Element
        can :manage, LaissCms::Ingredient
        can [:crop], LaissCms::Ingredients::Picture
        can :manage, LaissCms::LegacyPageUrl
        can :manage, LaissCms::Node
        can [:read, :url], LaissCms::Picture
        can [:read, :autocomplete], LaissCms::Tag
        can :edit_content, LaissCms::Page, LaissCms::Page.all do |page|
          page.editable_by?(@user)
        end
      end
    end

    # == Editor rules
    #
    # Includes author rules
    #
    module EditorUser
      include LaissCms::Permissions::AuthorUser

      def laiss_cms_editor_rules
        laiss_cms_author_rules

        # Navigation
        can :index, [
          :laiss_cms_admin_languages,
          :laiss_cms_admin_users
        ]

        # Resources
        can [
          :copy,
          :copy_language_tree,
          :flush,
          :order,
          :switch_language
        ], LaissCms::Page

        # Resources which may be locked via template permissions
        #
        #     # config/laiss_cms/page_layouts.yml
        #     - name: contact
        #       editable_by:
        #         - freelancer
        #         - admin
        #
        can([
          :create,
          :destroy
        ], LaissCms::Page) { |p| p.editable_by?(@user) }

        can(:publish, LaissCms::Page) do |page|
          page.language.public? && page.editable_by?(@user)
        end

        can :manage, LaissCms::Picture
        can :manage, LaissCms::PictureDescription
        can :manage, LaissCms::Attachment
        can :manage, LaissCms::Tag
        can :index, LaissCms::Language
        can :switch, LaissCms::Language
      end
    end

    # == Admin rules
    #
    # Includes editor rules
    #
    module AdminUser
      include LaissCms::Permissions::EditorUser

      def laiss_cms_admin_rules
        laiss_cms_editor_rules

        # Navigation
        can :index, [:laiss_cms_admin_sites, :laiss_cms_admin_styleguide]

        # Settings. Only admins may read or change engine-wide configuration;
        # authors and editors keep working with the defaults. The theme toggle
        # is deliberately NOT gated here — it is a per-user preference.
        can [:show, :update], :laiss_cms_admin_settings

        # Controller actions
        can [:info, :update_check], :laiss_cms_admin_dashboard

        # Resources
        can :manage, LaissCms::Language
        can :manage, LaissCms::Site
      end
    end

    private

    def user_role_rules
      return laiss_cms_guest_user_rules if @user.laiss_cms_roles.blank?

      @user.laiss_cms_roles.each do |role|
        exec_role_rules(role)
      end
    end

    def exec_role_rules(role)
      meth = :"laiss_cms_#{role}_rules"
      send(meth) if respond_to?(meth)
    end

    def set_action_aliases
      alias_action :configure,
        :fold,
        :info,
        :link,
        :read,
        :update,
        :unlock,
        :visit,
        :tree,
        to: :edit_content
    end

    # Include the role specific permissions.
    include GuestUser
    include MemberUser
    include AuthorUser
    include EditorUser
    include AdminUser
  end
end
