# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_picture_thumbs
#
#  id         :integer          not null, primary key
#  signature  :string           not null
#  uid        :text             not null
#  picture_id :integer          not null
#
# Indexes
#
#  index_laiss_cms_picture_thumbs_on_picture_id  (picture_id)
#  index_laiss_cms_picture_thumbs_on_signature   (signature) UNIQUE
#
# Foreign Keys
#
#  picture_id  (picture_id => laiss_cms_pictures.id)
#
module LaissCms
  # The persisted version of a rendered picture variant
  #
  # You can configure the generator class to implement a
  # different thumbnail store (ie. a remote file storage).
  #
  #     config/initializers/laiss_cms.rb
  #     LaissCms::PictureThumb.storage_class = My::ThumbnailStore
  #
  class PictureThumb < BaseRecord
    belongs_to :picture, class_name: "LaissCms::Picture"

    validates :signature, presence: true
    validates :uid, presence: true

    class << self
      # Thumbnail storage class
      #
      # @see LaissCms::PictureThumb::FileStore
      def storage_class
        @_storage_class ||= LaissCms::PictureThumb::FileStore
      end

      # Set a thumbnail storage class
      #
      # @see LaissCms::PictureThumb::FileStore
      def storage_class=(klass)
        @_storage_class = klass
      end

      # Upfront generation of picture thumbnails
      #
      # Called after a LaissCms::Picture has been created (after an image has been uploaded)
      #
      # Generates three types of thumbnails that are used by LaissCMS's picture archive and
      # persists them in the configures file store (Default Dragonfly::FileDataStore).
      #
      # @see Picture::THUMBNAIL_SIZES
      def generate_thumbs!(picture)
        LaissCms::Picture::THUMBNAIL_SIZES.values.each do |size|
          variant = LaissCms::PictureVariant.new(picture, {
            size: size,
            flatten: true
          })
          signature = LaissCms::PictureThumb::Signature.call(variant)
          thumb = find_by(signature: signature)
          next if thumb

          uid = LaissCms::PictureThumb::Uid.call(signature, variant)
          LaissCms::PictureThumb::Create.call(variant, signature, uid)
        end
      end
    end
  end
end
