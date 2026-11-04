require "laiss_cms/version"

module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class SystemInfo < ViewComponent::Base
          delegate :laiss_cms, :render_message, :render_icon, :link_to_dialog, to: :helpers

          def initialize
            @laiss_cms_version = LaissCms.version
          end

          private

          def license
            license_id = Gem.loaded_specs["laiss_cms"]&.license
            LaissCms.t(license_id, scope: :licenses) if license_id
          end

          def logo
            @_logo_file ||= File.read(logo_file_path).html_safe
          end

          def git_source
            git_info = LaissCms.git_revision_info
            return unless git_info

            branch = git_info[:branch]
            revision = git_info[:revision]

            "(#{[branch, revision[0, 7]].compact.join(" @ ")})"
          end

          def logo_file_path
            LaissCms::Engine.root.join("app/assets/images/laiss_cms/admin/logo.svg")
          end
        end
      end
    end
  end
end
