# frozen_string_literal: true

# This migration comes from laiss_cms (originally 20260102121232)
class AddMetadataToPageVersions < ActiveRecord::Migration[7.2]
  def change
    add_column :laiss_cms_page_versions, :title, :string
    add_column :laiss_cms_page_versions, :meta_description, :text
    add_column :laiss_cms_page_versions, :meta_keywords, :text
  end
end
