# frozen_string_literal: true

class AddSearchableToLaissCmsPages < ActiveRecord::Migration[7.2]
  def change
    return if column_exists?(:laiss_cms_pages, :searchable)

    add_column :laiss_cms_pages, :searchable, :boolean, default: true, null: false
  end
end
