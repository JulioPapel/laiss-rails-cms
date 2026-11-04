module LaissCms
  module UserMethods
    extend ActiveSupport::Concern

    included do
      # Unlock all locked pages before destroy.
      before_destroy :unlock_pages!

      scope :laiss_cms_admins, -> { with_laiss_cms_role(:admin) }

      scope :with_laiss_cms_role, ->(role) {
        role = role.to_s.downcase
        unless LaissCms.config.user_roles.include?(role)
          LaissCms::Logger.warn("Unknown LaissCms role: #{role.inspect}")
        end

        col = arel_table[:laiss_cms_roles]
        where(
          col.eq(role)
            .or(col.matches("#{role} %"))
            .or(col.matches("% #{role} %"))
            .or(col.matches("% #{role}"))
        )
      }

      validates :laiss_cms_roles,
        inclusion: {
          in: LaissCms.config.user_roles,
          message: "is not included in #{LaissCms.config.user_roles.join(", ")}"
        }

      # Returns all pages locked by user.
      #
      # A page gets locked when the user starts to edit the page.
      #
      has_many :locked_pages,
        -> { order(:locked_at) },
        foreign_key: :locked_by,
        class_name: "LaissCms::Page",
        inverse_of: :locker
    end

    class_methods do
      def human_laiss_cms_rolename(role)
        LaissCms.t("user_roles.#{role}")
      end
    end

    def laiss_cms_admin?
      has_laiss_cms_role?("admin")
    end

    def laiss_cms_roles
      if self.class.columns_hash["laiss_cms_roles"]
        read_attribute(:laiss_cms_roles).to_s.split(" ")
      else
        LaissCms::Logger.warn <<-WARN.strip_heredoc
          The `laiss_cms_roles` column is missing in the #{self.class.table_name} table!

          Please run

            rails generate laiss_cms:user_columns_migration

          to add it.

          Falling back to default role: `member`.
        WARN
        ["member"]
      end
    end

    def laiss_cms_roles=(roles)
      roles = Array(roles).map { _1.to_s.strip }
      roles.reject!(&:blank?)
      roles.uniq!
      super(roles.join(" "))
    end

    # Returns true if the user has the given role.
    def has_laiss_cms_role?(role)
      laiss_cms_roles.include?(role.to_s)
    end

    def human_laiss_cms_roles
      laiss_cms_roles.map do |role|
        self.class.human_laiss_cms_rolename(role)
      end.to_sentence
    end

    # Calls unlock on all locked pages
    def unlock_pages!
      locked_pages.each(&:unlock!)
    end
  end
end
