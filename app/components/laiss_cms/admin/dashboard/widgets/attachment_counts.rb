module LaissCms
  module Admin
    module Dashboard
      module Widgets
        class AttachmentCounts < StatWidget
          private

          def title = LaissCms::Attachment.model_name.human(count: :many)
          def link = laiss_cms.admin_attachments_path
          def icon = "file-copy-2"
          def count = LaissCms::Attachment.count
          def infos = number_to_human_size(LaissCms::Attachment.sum(&:file_size))
        end
      end
    end
  end
end
