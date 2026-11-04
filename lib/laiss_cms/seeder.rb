# frozen_string_literal: true

require "laiss_cms/shell"

module LaissCms
  # This seeder builds LaissCms pages in your database.
  #
  # Create a +db/seeds/laiss_cms/pages.yml+ and +db/seeds/laiss_cms/users.yml+ files
  # and put +LaissCms::Seeder.seed!+ into your +db/seeds.rb+ file.
  #
  # Then run +rake db:seed+
  #
  class Seeder
    extend LaissCms::Shell

    class << self
      # Put +LaissCms::Seeder.seed!+ into your +db/seeds.rb+ file and run +rake db:seed+.
      #
      def seed!
        try_seed_pages
        seed_users if user_seeds_file.file?
      end

      protected

      def try_seed_pages
        return unless page_seeds_file.file?

        if LaissCms::Page.exists?
          desc "Seeding LaissCms pages"
          log "There are already pages present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
        else
          create_default_site! unless LaissCms::Site.first
          create_default_language! unless LaissCms::Language.default
          seed_pages if contentpages.present?
          seed_layoutpages if layoutpages.present?
        end
      end

      def seed_pages
        desc "Seeding LaissCms content pages from #{page_seeds_file}"
        if contentpages.length > 1
          abort "The pages seed file must only contain one root page! You have #{contentpages.length}."
        end

        contentpages.each do |page|
          create_page(page, {
            language: LaissCms::Language.default,
            language_root: true
          })
        end
      end

      def seed_layoutpages
        desc "Seeding LaissCms layout pages from #{page_seeds_file}"
        language = LaissCms::Language.default
        layoutpages.each do |page|
          create_page(page, {language: language})
        end
      end

      def seed_users
        desc "Seeding LaissCms users from #{user_seeds_file}"

        if LaissCms.config.user_class.exists?
          log "There are already users present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
          false
        else
          users = load_yaml_file(user_seeds_file)
          users.each do |draft|
            user = LaissCms.config.user_class.create!(draft)
            log "Created user: #{user.try(:email) || user.try(:login) || user.id}"
          end
        end
      end

      private

      def page_seeds_file
        @_page_seeds_file ||= Rails.root.join("db", "seeds", "laiss_cms", "pages.yml")
      end

      def page_yml
        @_page_yml ||= load_yaml_file(
          page_seeds_file
        )
      end

      def load_yaml_file(file)
        YAML.safe_load_file(
          file,
          permitted_classes: [Date, Symbol],
          aliases: true
        )
      end

      def contentpages
        page_yml.reject { |p| p["layoutpage"] }
      end

      def layoutpages
        page_yml.select { |p| p["layoutpage"] }
      end

      def user_seeds_file
        @_user_seeds_file ||= Rails.root.join("db", "seeds", "laiss_cms", "users.yml")
      end

      def create_page(draft, attributes = {})
        children = draft.delete("children") || []
        page = LaissCms::Page.new(draft.merge(attributes))
        page.save!
        log "Created page: #{page.name}"
        children.each do |child|
          create_page(child, parent: page, language: page.language)
        end
      end

      # If no languages are present, create a default language based
      # on the host app's LaissCms configuration.
      def create_default_language!
        default_language = LaissCms.config.default_language
        if default_language
          LaissCms::Language.create!(
            name: default_language["name"],
            language_code: default_language["code"],
            locale: default_language["code"],
            frontpage_name: default_language["frontpage_name"],
            page_layout: default_language["page_layout"],
            public: true,
            default: true,
            site: LaissCms::Site.first
          )
        else
          raise DefaultLanguageNotFoundError
        end
      end

      def create_default_site!
        default_site = LaissCms.config.default_site
        if default_site
          LaissCms::Site.create!(name: default_site["name"], host: default_site["host"])
        else
          raise DefaultSiteNotFoundError
        end
      end
    end
  end
end
