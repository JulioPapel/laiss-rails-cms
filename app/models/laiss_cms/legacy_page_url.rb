# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_legacy_page_urls
#
#  id         :integer          not null, primary key
#  urlname    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer          not null
#
# Indexes
#
#  index_laiss_cms_legacy_page_urls_on_page_id  (page_id)
#  index_laiss_cms_legacy_page_urls_on_urlname  (urlname)
#

class LaissCms::LegacyPageUrl < ActiveRecord::Base
  belongs_to :page,
    class_name: "LaissCms::Page",
    required: true

  validates :urlname,
    presence: true,
    format: {with: /\A[:.\w\-+_\/?&%;=#]*\z/}
end
