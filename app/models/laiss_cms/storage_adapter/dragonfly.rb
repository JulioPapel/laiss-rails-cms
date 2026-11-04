module LaissCms
  class StorageAdapter
    module Dragonfly
      module PictureClassMethods
        def self.included(base)
          base.class_eval do
            dragonfly_accessor :image_file, app: :laiss_cms_pictures do
              # Preprocess after uploading the picture
              after_assign do |image|
                if has_convertible_format?
                  LaissCms.storage_adapter.preprocessor_class.new(image).call
                end
              end
            end

            has_many :thumbs, class_name: "LaissCms::PictureThumb", dependent: :destroy

            before_save if: :image_file_name do
              self.image_file_name = sanitized_filename(image_file_name)
            end

            # Create important thumbnails upfront
            after_create -> { PictureThumb.generate_thumbs!(self) },
              if: :has_convertible_format?
          end
        end
      end

      module AttachmentClassMethods
        def self.included(base)
          base.class_eval do
            dragonfly_accessor :file, app: :laiss_cms_attachments do
              after_assign { |file|
                write_attribute(:file_mime_type, file.mime_type)
              }
            end

            before_save if: :file_name do
              self.file_name = sanitized_filename(file_name)
            end
          end
        end
      end

      extend self

      CONVERTIBLE_FILE_FORMATS = %w[gif jpg jpeg png webp].freeze

      # Allows to set a custom Attachment Url class
      def attachment_url_class=(klass)
        @_attachment_url_class = klass
      end

      # Returns the class used to generate attachment urls
      # @return [Class] - defaults to LaissCms::StorageAdapter::Dragonfly::AttachmentUrl
      def attachment_url_class
        @_attachment_url_class ||= AttachmentUrl
      end

      def preprocessor_class
        Preprocessor
      end

      # Allows to set a custom Picture Url class
      def picture_url_class=(klass)
        @_picture_url_class = klass
      end

      # Returns the class used to generate picture urls
      # @return [Class] - defaults to LaissCms::StorageAdapter::Dragonfly::PictureUrl
      def picture_url_class
        @_picture_url_class ||= PictureUrl
      end

      def file_formats(class_name, scope:)
        mime_type_column = case class_name
        when "LaissCms::Attachment" then :file_mime_type
        when "LaissCms::Picture" then :image_file_format
        end

        scope.reorder(mime_type_column).distinct.pluck(mime_type_column).compact.presence || []
      end

      # @param [String]
      # @return [Array<String>]
      def searchable_laiss_cms_resource_attributes(class_name)
        case class_name
        when "LaissCms::Attachment"
          %w[name file_name]
        when "LaissCms::Picture"
          %w[name image_file_name]
        end
      end
      alias_method :ransackable_attributes, :searchable_laiss_cms_resource_attributes

      # @param [String]
      # @return [Array<String>]
      def ransackable_associations(_class_name)
        %w[]
      end

      def rescuable_errors
        ::Dragonfly::Job::Fetch::NotFound
      end

      # @param [String, Array<String>]
      # @return [LaissCms::Picture::ActiveRecord_Relation]
      def by_file_format_scope(file_format)
        Picture.where(image_file_format: file_format)
      end

      # @param [String, Array<String>]
      # @return [LaissCms::Attachment::ActiveRecord_Relation]
      def by_file_type_scope(file_type)
        Attachment.where(file_mime_type: file_type)
      end

      # @param [String, Array<String>]
      # @return [LaissCms::Attachment::ActiveRecord_Relation]
      def not_file_type_scope(file_type)
        Attachment.where.not(file_mime_type: file_type)
      end

      # @param [LaissCms::Attachment]
      # @return [String]
      def file_name(attachment)
        attachment.read_attribute(:file_name)
      end

      # @param [LaissCms::Attachment]
      # @return [String]
      def file_basename(attachment)
        attachment.file&.basename&.to_s
      end

      # @param [LaissCms::Attachment]
      # @return [Integer]
      def file_size(attachment)
        attachment.read_attribute(:file_size)
      end

      # @param [LaissCms::Attachment]
      # @return [String]
      def file_mime_type(attachment)
        attachment.read_attribute(:file_mime_type)
      end

      # @param [LaissCms::Attachment]
      # @return [String]
      def file_extension(attachment)
        extension = File.extname(file_name(attachment).to_s).delete_prefix(".").downcase
        return extension if extension.present?

        # Marcel returns the canonical extension for a mime type, which is not
        # always the one the file was named after: `audio/mpeg` yields `mpga`,
        # not `mp3`. Only reach for it when the name has no extension at all.
        content_type = file_mime_type(attachment)
        Marcel::Magic.new(content_type).extensions.first if content_type
      end

      # @param [LaissCms::Picture]
      # @return [TrueClass, FalseClass]
      def has_convertible_format?(picture)
        image_file_extension(picture).in?(CONVERTIBLE_FILE_FORMATS)
      end

      # @param [LaissCms::Picture]
      # @return [String]
      def image_file_basename(picture)
        picture.image_file&.basename&.to_s
      end

      # @param [LaissCms::Picture]
      # @return [String]
      def image_file_name(picture)
        picture.read_attribute(:image_file_name)
      end

      # @param [LaissCms::Picture]
      # @return [String]
      def image_file_format(picture)
        ext = picture.read_attribute(:image_file_format)
        Marcel::MimeType.for(extension: ext) if ext
      end

      # @param [LaissCms::Picture]
      # @return [Integer]
      def image_file_size(picture)
        picture.read_attribute(:image_file_size)
      end

      # @param [LaissCms::Picture]
      # @return [Integer]
      def image_file_width(picture)
        picture.read_attribute(:image_file_width)
      end

      # @param [LaissCms::Picture]
      # @return [Integer]
      def image_file_height(picture)
        picture.read_attribute(:image_file_height)
      end

      # @param [LaissCms::Picture]
      # @return [String]
      def image_file_extension(picture)
        picture.read_attribute(:image_file_format)
      end

      # @param [LaissCms::Picture]
      # @return [TrueClass, FalseClass]
      def image_file_present?(picture)
        !!picture.image_file
      end

      # @param LaissCms::Picture::ActiveRecord_Relation
      # @return LaissCms::Picture::ActiveRecord_Relation
      def preloaded_pictures(pictures)
        pictures.includes(:thumbs)
      end

      # Preload picture associations on already-loaded records
      # @param [Array<LaissCms::Picture>] pictures
      def preload_picture_associations(pictures)
        ActiveRecord::Associations::Preloader.new(
          records: pictures,
          associations: :thumbs
        ).call
      end

      # @param [LaissCms::Attachment]
      # @return [TrueClass, FalseClass]
      def set_attachment_name?(attachment)
        attachment.file_name_changed?
      end
    end
  end
end
