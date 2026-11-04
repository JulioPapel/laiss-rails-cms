# frozen_string_literal: true

class AddPermittedRolesToLaissCmsPages < ActiveRecord::Migration[7.2]
  # Only SQLite needs this: it has no real ALTER TABLE, so the remove_column in
  # down rebuilds the table via DROP TABLE, whose implicit DELETE cascades into
  # laiss_cms_page_versions, laiss_cms_elements and laiss_cms_ingredients. The
  # adapter's PRAGMA foreign_keys = OFF guard against that is a silent no-op
  # inside a transaction.
  disable_ddl_transaction! if connection.adapter_name.match?(/sqlite/i)

  def up
    # Adding a nullable column is a plain ALTER TABLE ADD COLUMN, so up can keep
    # the atomicity the declaration above gives up for both directions.
    connection.transaction do
      add_column :laiss_cms_pages, :permitted_roles, :text, if_not_exists: true
      execute(%(UPDATE #{quote_table_name("laiss_cms_pages")} SET permitted_roles = '["member"]' WHERE permitted_roles IS NULL))
    end
  end

  def down
    remove_column :laiss_cms_pages, :permitted_roles, if_exists: true
  end
end
