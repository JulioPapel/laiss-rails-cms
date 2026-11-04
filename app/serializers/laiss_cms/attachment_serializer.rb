# frozen_string_literal: true

module LaissCms
  class AttachmentSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :file_name,
      :file_mime_type,
      :file_size,
      :icon_css_class,
      :tag_list,
      :created_at,
      :updated_at

    attribute :url do
      LaissCms::Engine.routes.url_helpers.download_attachment_path(
        id: object.id,
        name: object.file_name
      )
    end
  end
end
