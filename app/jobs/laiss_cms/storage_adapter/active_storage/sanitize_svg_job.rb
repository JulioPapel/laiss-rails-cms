# frozen_string_literal: true

require "laiss_cms/svg_scrubber"

module LaissCms
  class StorageAdapter
    class ActiveStorage::SanitizeSvgJob < BaseJob
      # @param [LaissCms::Attachment, LaissCms::Picture] attachable
      # @param [Symbol] file_accessor - :file for LaissCms::Attachment, :image_file for LaissCms::Picture
      def perform(attachable, file_accessor: :image_file)
        return unless attachable.svg?

        blob = attachable.send(file_accessor).blob
        return if blob.metadata[:sanitized]

        sanitized = sanitize(blob.download)

        Tempfile.create([blob.filename.base, blob.filename.extension]) do |file|
          file.puts(sanitized)
          file.rewind
          blob.upload(file)
        end

        blob.metadata[:sanitized] = true
        blob.save!
      end

      private

      def sanitize(unsafe_xml)
        unsafe_xml = unsafe_xml.to_s
        unsafe_xml.force_encoding("UTF-8")
        scrubber = SvgScrubber.new
        if document?(unsafe_xml)
          ::Loofah.xml_document(unsafe_xml).scrub!(scrubber).to_s
        else
          ::Loofah.xml_fragment(unsafe_xml).scrub!(scrubber).to_s
        end
      end

      def document?(unsafe)
        unsafe.include?("<?xml") || unsafe.include?("<!DOCTYPE")
      end
    end
  end
end
