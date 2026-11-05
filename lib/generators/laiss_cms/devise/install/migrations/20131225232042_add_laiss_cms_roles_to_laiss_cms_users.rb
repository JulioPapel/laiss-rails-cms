class AddLaissCmsRolesToLaissCmsUsers < ActiveRecord::Migration[4.2]
  disable_ddl_transaction! if connection.adapter_name.match?(/sqlite/i)

  def up
    # Updating old :roles column (since LaissCms CMS v2.6)
    if column_exists?(:laiss_cms_users, :roles)
      rename_column :laiss_cms_users, :roles, :laiss_cms_roles
      change_column :laiss_cms_users, :laiss_cms_roles, :string, default: "member"
    end

    # Creating :laiss_cms_roles column for new apps.
    unless column_exists?(:laiss_cms_users, :laiss_cms_roles)
      add_column :laiss_cms_users, :laiss_cms_roles, :string, default: "member"
    end

    # Renaming the index
    if index_exists?(:laiss_cms_users, :roles)
      remove_index :laiss_cms_users, :roles
    end
    unless index_exists?(:laiss_cms_users, :laiss_cms_roles)
      add_index :laiss_cms_users, :laiss_cms_roles
    end
  end
end
