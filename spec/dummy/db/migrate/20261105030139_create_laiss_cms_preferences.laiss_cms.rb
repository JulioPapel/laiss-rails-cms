# frozen_string_literal: true

# This migration comes from laiss_cms (originally 20261105030000)
# Storage for values the admin reads and writes at runtime.
#
# Two things need to outlive a request and a server restart:
#
#   * a user's explicit light/dark choice, so it is honoured on the next login
#   * the engine settings the Settings screen exposes
#
# Both are small, scoped key/value facts, so they share one table rather than
# two. `scope` says what a row belongs to, `owner_id` narrows it to a user
# (NULL means engine-wide). The unique index makes writes idempotent.
#
# Everything reading these rows must tolerate the table being absent: a host
# app that upgrades the gem without running `laiss_cms:install:migrations` must
# still boot, so the reader falls back to defaults instead of raising.
class CreateLaissCmsPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :laiss_cms_preferences do |t|
      t.string :scope, null: false
      t.integer :owner_id
      t.string :key, null: false
      t.text :value
      t.timestamps
    end

    add_index :laiss_cms_preferences, %i[scope owner_id key], unique: true,
      name: "index_laiss_cms_preferences_unique"
  end
end
