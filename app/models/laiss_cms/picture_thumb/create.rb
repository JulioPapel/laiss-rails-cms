# frozen_string_literal: true

module LaissCms
  class PictureThumb < BaseRecord
    # Creates a LaissCms::PictureThumb
    #
    # Stores the processes result of a LaissCms::PictureVariant
    # in the configured +LaissCms::PictureThumb.storage_class+
    # (Default: {LaissCms::PictureThumb::FileStore})
    #
    class Create
      class << self
        # @param [LaissCms::PictureVariant] variant the to be rendered image
        # @param [String] signature A unique hashed version of the rendering options
        # @param [String] uid The Unique Image Identifier the image is stored at
        #
        # @return [LaissCms::PictureThumb] The persisted thumbnail record
        #
        def call(variant, signature, uid)
          return if !variant.picture.valid?

          # create the thumb before storing
          # to prevent db race conditions
          @thumb = LaissCms::PictureThumb.create_or_find_by!(signature: signature) do |thumb|
            thumb.picture = variant.picture
            thumb.uid = uid
          end
          begin
            LaissCms::PictureThumb.storage_class.call(variant, uid)
          rescue => e
            ErrorTracking.notification_handler.call(e)
            # destroy the thumb if processing or storing fails
            @thumb&.destroy
          end
        end
      end
    end
  end
end
