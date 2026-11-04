# frozen_string_literal: true

module LaissCms
  module Admin
    module AttachmentsHelper
      include LaissCms::Admin::BaseHelper
      include LaissCms::Filetypes

      def mime_to_human(mime)
        LaissCms.t(mime, scope: "mime_types", default: LaissCms.t(:document))
      end

      def attachment_preview_size(attachment)
        case attachment.file_mime_type
        when "application/pdf" then "850x600"
        when *IMAGE_FILE_TYPES then "850x280"
        when *AUDIO_FILE_TYPES then "850x190"
        when *VIDEO_FILE_TYPES then "850x240"
        else
          "500x165"
        end
      end
    end
  end
end
