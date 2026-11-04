# This migration comes from laiss_cms_devise (originally 20260410115756)
class AddTimezoneToLaissCmsUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :laiss_cms_users, :timezone, :string, if_not_exists: true,
      comment: "The timezone of the user, used for displaying dates in the user's timezone"
  end
end
