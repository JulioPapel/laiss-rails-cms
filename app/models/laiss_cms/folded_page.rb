# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_folded_pages
#
#  id      :integer          not null, primary key
#  folded  :boolean          default(FALSE), not null
#  page_id :integer          not null
#  user_id :integer          not null
#
# Indexes
#
#  index_laiss_cms_folded_pages_on_page_id_and_user_id  (page_id,user_id) UNIQUE
#

module LaissCms
  class FoldedPage < BaseRecord
    belongs_to :page, inverse_of: :folded_pages
    belongs_to :user, inverse_of: :folded_pages, class_name: LaissCms.config.user_class_name

    def self.folded_for_user(user)
      return none unless LaissCms.config.user_class.respond_to?(:where)

      where(user: user, folded: true)
    end
  end
end
