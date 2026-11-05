module LaissCms
  module Admin
    # The current user, as a control in the admin header.
    #
    # Markup source: theme/index.html — the header profile control,
    # `li.nav-item.header-profile > a.nav-link > i`, which the theme renders beside its
    # notification bell. The theme's own version is a dropdown containing Profile /
    # Inbox / Logout, driven by Bootstrap's JavaScript. This project ships no Bootstrap
    # JS (no jQuery either), so the dropdown half cannot be adopted as-is; what is
    # adopted is the control's SHAPE — a nav-link with an icon and a label, sized and
    # padded like the other header controls rather than sitting as bare text.
    #
    # The theme's `.btn` and `.nav-link` are both present in theme.css, but neither is
    # used here: they bring Bootstrap's 1rem font size and .375rem/.75rem padding, which
    # are too large for a 34px header row and would fight the existing header control
    # grammar in modern_components.scss. The control keeps the admin's own pill radius
    # and height, which is what makes it read as a button beside the locale and timezone
    # selects.
    #
    # Two separate things made this read as text before:
    #
    #   1. `link_to_if(edit_user_path, ...)` — when `edit_user_path` is nil (the default
    #      configuration, and the demo app's), link_to_if renders NO tag at all, just the
    #      bare string. There was no element to style as a button.
    #   2. The only rule that would have dressed it targeted `laiss-cms-current-user-name`,
    #      an element name this component has never emitted. The real class is
    #      `.current-user-name`, so the rule never matched.
    #
    # A span is always emitted now, so the control has a box whether or not the user is
    # editable. When there is a path it is an <a>; when there is not, it is still a
    # button-shaped surface — the identity is shown either way.
    class CurrentUserName < ViewComponent::Base
      def initialize(user:)
        @user = user
        @display_name = user.try(:laiss_cms_display_name)
      end

      def call
        tag.span class: "current-user-name", title: display_name do
          safe_join [
            '<laiss-cms-icon name="user" size="1x"></laiss-cms-icon>'.html_safe,
            label
          ]
        end
      end

      def render?
        user && display_name.present?
      end

      private

      attr_reader :user, :display_name

      # Always an element, never a bare string: see the note on the class.
      def label
        if edit_user_path
          link_to display_name, edit_user_path
        else
          tag.span display_name, class: "current-user-name__text"
        end
      end

      def edit_user_path
        return unless LaissCms.config.edit_user_path

        LaissCms.config.edit_user_path.gsub(":id", user.id.to_s)
      end
    end
  end
end
