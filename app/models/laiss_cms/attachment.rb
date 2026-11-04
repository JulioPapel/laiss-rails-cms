# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_attachments
#
#  id              :integer          not null, primary key
#  cached_tag_list :text
#  file_mime_type  :string
#  file_name       :string
#  file_size       :integer
#  file_uid        :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_id      :integer
#  updater_id      :integer
#
# Indexes
#
#  index_laiss_cms_attachments_on_created_at  (created_at)
#  index_laiss_cms_attachments_on_creator_id  (creator_id)
#  index_laiss_cms_attachments_on_file_uid    (file_uid)
#  index_laiss_cms_attachments_on_updater_id  (updater_id)
#

module LaissCms
  class Attachment < BaseRecord
    include LaissCms::Filetypes
    include LaissCms::NameConversions
    include LaissCms::Taggable
    include LaissCms::TouchElements
    include LaissCms::RelatableResource

    before_save :set_name, if: -> { LaissCms.storage_adapter.set_attachment_name?(self) }

    include LaissCms.storage_adapter.attachment_class_methods

    stampable stamper_class_name: LaissCms.config.user_class_name

    scope :by_file_type, ->(*file_type) do
      LaissCms.storage_adapter.by_file_type_scope(file_type)
    end

    scope :not_file_type, ->(*file_type) do
      LaissCms.storage_adapter.not_file_type_scope(file_type)
    end

    scope :recent, -> { where("#{table_name}.created_at > ?", Time.current - 24.hours).order(:created_at) }
    scope :without_tag, -> { left_outer_joins(:taggings).where(gutentag_taggings: {id: nil}) }

    # Override +LaissCms::RelatableResource#deletable+ to also exclude
    # attachments referenced from +/attachment/:id/download+ URLs inside
    # ingredient values (e.g. Richtext markup, Link ingredients, raw Html).
    # Those URLs are written by the file tab of the link dialog and are
    # not tracked via the polymorphic +related_object+ association, so the
    # base scope cannot see them.
    #
    # Extracts referenced attachment IDs from ingredient values via Ruby
    # regex to stay database-agnostic.
    scope :deletable, -> do
      referenced_ids = LaissCms::Ingredient
        .where("value LIKE '%/attachment/%/download%'")
        .pluck(:value)
        .flat_map { |v| v.scan(%r{/attachment/(\d+)/download}).flatten.map(&:to_i) }

      scope = where("#{table_name}.id NOT IN (#{RelatableResource::RELATED_INGREDIENTS_SUBQUERY})", type: name)
      referenced_ids.any? ? scope.where.not(id: referenced_ids) : scope
    end

    # We need to define this method here to have it available in the validations below.
    class << self
      # The class used to generate URLs for attachments
      #
      def url_class
        @_url_class ||= LaissCms.storage_adapter.attachment_url_class
      end

      # Set a different attachment url class
      #
      # @see LaissCms::Attachment::Url
      def url_class=(klass)
        @_url_class = klass
      end

      def last_upload
        last_id = Attachment.maximum(:id)
        return Attachment.all unless last_id

        where(id: last_id)
      end

      def searchable_laiss_cms_resource_attributes
        LaissCms.storage_adapter.searchable_laiss_cms_resource_attributes(name)
      end

      def ransackable_attributes(_auth_object = nil)
        LaissCms.storage_adapter.ransackable_attributes(name)
      end

      def ransackable_associations(_auth_object = nil)
        LaissCms.storage_adapter.ransackable_associations(name)
      end

      def file_types(scope = all, from_extensions: nil)
        if from_extensions.present?
          scope = by_file_type(
            Array(from_extensions).map { |extension| Marcel::MimeType.for(extension:) }
          )
        end
        LaissCms.storage_adapter.file_formats(name, scope:)
      end

      def allowed_filetypes
        LaissCms.config.uploader.allowed_filetypes.laiss_cms_attachments
      end

      def ransackable_scopes(_auth_object = nil)
        %i[by_file_type not_file_type recent last_upload without_tag deletable]
      end
    end

    validates_presence_of :file
    validates_size_of :file, maximum: LaissCms.config.uploader.file_size_limit.megabytes
    validate :file_type_allowed,
      unless: -> { self.class.allowed_filetypes.include?("*") }

    scope :with_file_type, ->(file_type) { where(file_mime_type: file_type) }

    # Instance methods

    def url(options = {})
      self.class.url_class.new(self).call(options)
    end

    # An url save filename without format suffix
    def slug
      CGI.escape(file_name.gsub(/\.#{extension}$/, "").tr(".", " "))
    end

    # Override +LaissCms::RelatableResource#deletable?+ to also consider
    # +/attachment/:id/download+ links inside ingredient values (e.g.
    # Richtext markup, Link ingredients, raw Html).
    def deletable?
      super && !referenced_in_ingredient_value?
    end

    # Checks if the attachment is restricted, because it is attached on restricted pages only
    def restricted?
      related_pages.any? && related_pages.not_restricted.blank?
    end

    # File name
    def file_name
      LaissCms.storage_adapter.file_name(self)
    end

    # File size
    def file_size
      LaissCms.storage_adapter.file_size(self)
    end

    def file_mime_type
      LaissCms.storage_adapter.file_mime_type(self)
    end

    # File format suffix
    def extension
      LaissCms.storage_adapter.file_extension(self)
    end
    alias_method :suffix, :extension

    def svg?
      file_mime_type == "image/svg+xml"
    end

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case file_mime_type
      when "application/pdf"
        "file-pdf-2"
      when *TEXT_FILE_TYPES
        "file-text"
      when *EXCEL_FILE_TYPES
        "file-excel-2"
      when *POWERPOINT_FILE_TYPES
        "file-ppt-2"
      when *WORD_FILE_TYPES
        "file-word-2"
      when *VCARD_FILE_TYPES
        "profile"
      when *ARCHIVE_FILE_TYPES
        "file-zip"
      when *AUDIO_FILE_TYPES
        "file-music"
      when *IMAGE_FILE_TYPES
        "file-image"
      when *VIDEO_FILE_TYPES
        "file-video"
      else
        "file-3"
      end
    end

    private

    def file_type_allowed
      unless extension&.downcase&.in?(self.class.allowed_filetypes.map(&:downcase))
        errors.add(:file, LaissCms.t("not a valid file"))
      end
    end

    def referenced_in_ingredient_value?
      LaissCms::Ingredient
        .where("value LIKE ?", "%/attachment/#{id}/download%")
        .exists?
    end

    def set_name
      self.name ||= LaissCms.storage_adapter.file_basename(self).humanize
    end
  end
end
