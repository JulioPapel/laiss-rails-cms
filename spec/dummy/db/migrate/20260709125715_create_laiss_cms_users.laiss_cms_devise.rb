# This migration comes from laiss_cms_devise (originally 20131015124700)
class CreateLaissCmsUsers < ActiveRecord::Migration[4.2]
  def up
    return if table_exists?(:laiss_cms_users)
    create_table "laiss_cms_users" do |t|
      t.string "firstname"
      t.string "lastname"
      t.string "login"
      t.string "email"
      t.string "language"
      t.string "encrypted_password", limit: 128, default: "", null: false
      t.string "password_salt", limit: 128, default: "", null: false
      t.integer "sign_in_count", default: 0, null: false
      t.integer "failed_attempts", default: 0, null: false
      t.datetime "last_request_at"
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "creator_id"
      t.integer "updater_id"
      t.text "cached_tag_list"
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
    end

    add_index "laiss_cms_users", ["email"], unique: true
    add_index "laiss_cms_users", ["login"], unique: true
    add_index "laiss_cms_users", ["reset_password_token"], unique: true
  end
end
