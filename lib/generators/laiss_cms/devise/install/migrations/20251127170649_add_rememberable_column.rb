class AddRememberableColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :laiss_cms_users, :remember_created_at, :datetime, if_not_exists: true
  end
end
