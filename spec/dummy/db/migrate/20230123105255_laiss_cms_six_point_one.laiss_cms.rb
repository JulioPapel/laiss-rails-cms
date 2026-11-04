# frozen_string_literal: true

# This migration comes from laiss_cms (originally 20230121212637)
class LaissCmsSixPointOne < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  def up
    unless table_exists?("laiss_cms_attachments")
      create_table "laiss_cms_attachments" do |t|
        t.string "name"
        t.string "file_name"
        t.string "file_mime_type"
        t.integer "file_size"
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.string "file_uid"
        t.index ["creator_id"], name: "index_laiss_cms_attachments_on_creator_id"
        t.index ["file_uid"], name: "index_laiss_cms_attachments_on_file_uid"
        t.index ["updater_id"], name: "index_laiss_cms_attachments_on_updater_id"
      end
    end

    unless table_exists?("laiss_cms_elements_laiss_cms_pages")
      create_table "laiss_cms_elements_laiss_cms_pages", id: false do |t|
        t.integer "element_id"
        t.integer "page_id"
        t.index ["element_id"], name: "index_laiss_cms_elements_laiss_cms_pages_on_element_id"
        t.index ["page_id"], name: "index_laiss_cms_elements_laiss_cms_pages_on_page_id"
      end
    end

    unless table_exists?("laiss_cms_folded_pages")
      create_table "laiss_cms_folded_pages" do |t|
        t.integer "page_id", null: false
        t.integer "user_id", null: false
        t.boolean "folded", default: false, null: false
        t.index ["page_id", "user_id"], name: "index_laiss_cms_folded_pages_on_page_id_and_user_id", unique: true
      end
    end

    unless table_exists?("laiss_cms_sites")
      create_table "laiss_cms_sites" do |t|
        t.string "host"
        t.string "name"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.boolean "public", default: false, null: false
        t.text "aliases"
        t.boolean "redirect_to_primary_host", default: false, null: false
        t.index ["host", "public"], name: "laiss_cms_sites_public_hosts_idx"
        t.index ["host"], name: "index_laiss_cms_sites_on_host"
      end
    end

    unless table_exists?("laiss_cms_languages")
      create_table "laiss_cms_languages" do |t|
        t.string "name"
        t.string "language_code"
        t.string "frontpage_name"
        t.string "page_layout", default: "intro"
        t.boolean "public", default: false, null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer "creator_id"
        t.integer "updater_id"
        t.boolean "default", default: false, null: false
        t.string "country_code", default: "", null: false
        t.references "site", null: false, foreign_key: { to_table: :laiss_cms_sites }
        t.string "locale"
        t.index ["creator_id"], name: "index_laiss_cms_languages_on_creator_id"
        t.index ["language_code", "country_code"], name: "index_laiss_cms_languages_on_language_code_and_country_code"
        t.index ["language_code"], name: "index_laiss_cms_languages_on_language_code"
        t.index ["updater_id"], name: "index_laiss_cms_languages_on_updater_id"
      end
    end

    unless table_exists?("laiss_cms_legacy_page_urls")
      create_table "laiss_cms_legacy_page_urls" do |t|
        t.string "urlname", null: false
        t.integer "page_id", null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["page_id"], name: "index_laiss_cms_legacy_page_urls_on_page_id"
        t.index ["urlname"], name: "index_laiss_cms_legacy_page_urls_on_urlname"
      end
    end

    unless table_exists?("laiss_cms_pages")
      create_table "laiss_cms_pages" do |t|
        t.string "name"
        t.string "urlname"
        t.string "title"
        t.string "language_code"
        t.boolean "language_root", default: false, null: false
        t.string "page_layout"
        t.text "meta_keywords"
        t.text "meta_description"
        t.integer "lft"
        t.integer "rgt"
        t.integer "parent_id"
        t.integer "depth"
        t.integer "locked_by"
        t.boolean "restricted", default: false, null: false
        t.boolean "robot_index", default: true, null: false
        t.boolean "robot_follow", default: true, null: false
        t.boolean "sitemap", default: true, null: false
        t.boolean "layoutpage", default: false, null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer "creator_id"
        t.integer "updater_id"
        t.references "language", null: false, foreign_key: { to_table: :laiss_cms_languages }
        t.datetime "published_at", precision: nil
        t.datetime "locked_at", precision: nil
        t.index ["creator_id"], name: "index_laiss_cms_pages_on_creator_id"
        t.index ["locked_at", "locked_by"], name: "index_laiss_cms_pages_on_locked_at_and_locked_by"
        t.index ["parent_id", "lft"], name: "index_pages_on_parent_id_and_lft"
        t.index ["rgt"], name: "index_laiss_cms_pages_on_rgt"
        t.index ["updater_id"], name: "index_laiss_cms_pages_on_updater_id"
        t.index ["urlname"], name: "index_pages_on_urlname"
      end
    end

    unless table_exists?("laiss_cms_page_versions")
      create_table "laiss_cms_page_versions" do |t|
        t.references "page", null: false, foreign_key: { to_table: :laiss_cms_pages, on_delete: :cascade }
        t.datetime "public_on", precision: nil
        t.datetime "public_until", precision: nil
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["public_on", "public_until"], name: "index_laiss_cms_page_versions_on_public_on_and_public_until"
      end
    end

    unless table_exists?("laiss_cms_elements")
      create_table "laiss_cms_elements" do |t|
        t.string "name"
        t.integer "position"
        t.boolean "public", default: true, null: false
        t.boolean "folded", default: false, null: false
        t.boolean "unique", default: false, null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer "creator_id"
        t.integer "updater_id"
        t.integer "parent_element_id"
        t.boolean "fixed", default: false, null: false
        t.references "page_version", null: false, foreign_key: { to_table: :laiss_cms_page_versions, on_delete: :cascade }
        t.index ["creator_id"], name: "index_laiss_cms_elements_on_creator_id"
        t.index ["fixed"], name: "index_laiss_cms_elements_on_fixed"
        t.index ["page_version_id", "parent_element_id"], name: "idx_laiss_cms_elements_on_page_version_id_and_parent_element_id"
        t.index ["page_version_id", "position"], name: "idx_laiss_cms_elements_on_page_version_id_and_position"
        t.index ["updater_id"], name: "index_laiss_cms_elements_on_updater_id"
      end
    end

    unless table_exists?("laiss_cms_ingredients")
      create_table "laiss_cms_ingredients" do |t|
        t.references "element", null: false, foreign_key: { to_table: :laiss_cms_elements, on_delete: :cascade }
        t.string "type", null: false
        t.string "role", null: false
        t.text "value"
        if ActiveRecord::Migration.connection.adapter_name.match?(/postgres/i)
          t.jsonb :data, default: {}
        else
          t.json :data
        end
        t.string "related_object_type"
        t.integer "related_object_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["element_id", "role"], name: "index_laiss_cms_ingredients_on_element_id_and_role", unique: true
        t.index ["related_object_id", "related_object_type"], name: "idx_laiss_cms_ingredient_relation"
        t.index ["type"], name: "index_laiss_cms_ingredients_on_type"
      end
    end

    unless table_exists?("laiss_cms_nodes")
      create_table "laiss_cms_nodes" do |t|
        t.string "name"
        t.string "title"
        t.string "url"
        t.boolean "nofollow", default: false, null: false
        t.boolean "external", default: false, null: false
        t.boolean "folded", default: false, null: false
        t.integer "parent_id"
        t.integer "lft", null: false
        t.integer "rgt", null: false
        t.integer "depth", default: 0, null: false
        t.references "page", foreign_key: { to_table: :laiss_cms_pages, on_delete: :restrict }
        t.references "language", null: false, foreign_key: { to_table: :laiss_cms_languages }
        t.integer "creator_id"
        t.integer "updater_id"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.string "menu_type", null: false
        t.index ["creator_id"], name: "index_laiss_cms_nodes_on_creator_id"
        t.index ["lft"], name: "index_laiss_cms_nodes_on_lft"
        t.index ["parent_id"], name: "index_laiss_cms_nodes_on_parent_id"
        t.index ["rgt"], name: "index_laiss_cms_nodes_on_rgt"
        t.index ["updater_id"], name: "index_laiss_cms_nodes_on_updater_id"
      end
    end

    unless table_exists?("laiss_cms_pictures")
      create_table "laiss_cms_pictures" do |t|
        t.string "name"
        t.string "image_file_name"
        t.integer "image_file_width"
        t.integer "image_file_height"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.integer "creator_id"
        t.integer "updater_id"
        t.string "upload_hash"
        t.string "image_file_uid"
        t.integer "image_file_size"
        t.string "image_file_format"
        t.index ["creator_id"], name: "index_laiss_cms_pictures_on_creator_id"
        t.index ["updater_id"], name: "index_laiss_cms_pictures_on_updater_id"
      end
    end

    unless table_exists?("laiss_cms_picture_thumbs")
      create_table "laiss_cms_picture_thumbs" do |t|
        t.references "picture", null: false, foreign_key: { to_table: :laiss_cms_pictures }
        t.string "signature", null: false
        t.text "uid", null: false
        t.index ["signature"], name: "index_laiss_cms_picture_thumbs_on_signature", unique: true
      end
    end
  end

  def down
    drop_table "laiss_cms_attachments" if table_exists?("laiss_cms_attachments")
    drop_table "laiss_cms_elements" if table_exists?("laiss_cms_elements")
    drop_table "laiss_cms_elements_laiss_cms_pages" if table_exists?("laiss_cms_elements_laiss_cms_pages")
    drop_table "laiss_cms_folded_pages" if table_exists?("laiss_cms_folded_pages")
    drop_table "laiss_cms_ingredients" if table_exists?("laiss_cms_ingredients")
    drop_table "laiss_cms_languages" if table_exists?("laiss_cms_languages")
    drop_table "laiss_cms_legacy_page_urls" if table_exists?("laiss_cms_legacy_page_urls")
    drop_table "laiss_cms_nodes" if table_exists?("laiss_cms_nodes")
    drop_table "laiss_cms_page_versions" if table_exists?("laiss_cms_page_versions")
    drop_table "laiss_cms_pages" if table_exists?("laiss_cms_pages")
    drop_table "laiss_cms_picture_thumbs" if table_exists?("laiss_cms_picture_thumbs")
    drop_table "laiss_cms_pictures" if table_exists?("laiss_cms_pictures")
    drop_table "laiss_cms_sites" if table_exists?("laiss_cms_sites")
  end
end
