# This migration comes from laiss_cms_devise (originally 20141209144532)
class AddIndexesToLaissCmsUsers < ActiveRecord::Migration[4.2]
  def up
    add_index :laiss_cms_users, :firstname
    add_index :laiss_cms_users, :lastname
  end

  def down
    remove_index :laiss_cms_users, :firstname
    remove_index :laiss_cms_users, :lastname
  end
end
