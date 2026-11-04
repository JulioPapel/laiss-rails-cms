# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_page_versions
#
#  id               :integer          not null, primary key
#  meta_description :text
#  meta_keywords    :text
#  public_on        :datetime
#  public_until     :datetime
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  page_id          :integer          not null
#
# Indexes
#
#  index_laiss_cms_page_versions_on_page_id                     (page_id)
#  index_laiss_cms_page_versions_on_public_on_and_public_until  (public_on,public_until)
#
# Foreign Keys
#
#  page_id  (page_id => laiss_cms_pages.id) ON DELETE => cascade
#
module LaissCms
  class PageVersion < BaseRecord
    include LaissCms::Publishable

    # Metadata attributes that are versioned (moved from Page)
    METADATA_ATTRIBUTES = %w[
      title
      meta_description
      meta_keywords
    ].freeze

    belongs_to :page, class_name: "LaissCms::Page", inverse_of: :versions, touch: true

    has_many :elements, -> { order(:position) },
      class_name: "LaissCms::Element",
      inverse_of: :page_version

    before_create :set_title_from_page

    class << self
      alias_method :drafts, :draft
      deprecate drafts: :draft, deprecator: LaissCms::Deprecation

      alias_method :public_on, :published
      deprecate public_on: :published, deprecator: LaissCms::Deprecation
    end

    before_destroy :delete_elements

    def element_repository
      @element_repository ||= ElementsRepository.new(elements)
    end

    private

    def delete_elements
      DeleteElements.new(elements).call
    end

    def set_title_from_page
      return if title.present?

      self.title = page&.name
    end
  end
end
