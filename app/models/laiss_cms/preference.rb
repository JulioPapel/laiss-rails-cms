# frozen_string_literal: true

# == Schema Information
#
# Table name: laiss_cms_preferences
#
#  id         :integer          not null, primary key
#  key        :string           not null
#  scope      :string           not null
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :integer
#
# Indexes
#
#  index_laiss_cms_preferences_unique  (scope,owner_id,key) UNIQUE
#
module LaissCms
  # A small, scoped key/value store for values the admin writes at runtime.
  #
  # The engine's configuration has always been boot-time only: it is read from
  # YAML before the app initialises, and `LaissCms.config` is a plain object in
  # memory. That is fine for anything the host app decides once, but the Settings
  # screen needs somewhere to persist a change so it survives a restart, and a
  # user's light/dark choice needs somewhere to live across sessions.
  #
  # This record provides exactly that, and nothing more:
  #
  #   Preference.set(:theme, "dark", owner: user)   # this user only
  #   Preference.get(:theme, owner: user)           # => "dark"
  #   Preference.set(:settings, "site_name", "X")   # engine-wide
  #
  # When the table is missing (a host app that has not run the engine's
  # migrations yet) every reader returns the fallback and every writer is a
  # no-op, so the admin still boots and behaves exactly as before. That
  # degradation is deliberate: a missing migration must not take the admin down.
  class Preference < BaseRecord
    THEME = "theme"
    SETTINGS = "settings"

    validates :scope, presence: true
    validates :key, presence: true

    class << self
      # Memoised only when true: a negative answer is cheap to re-derive and
      # must not stick after the migration has been run.
      def available?
        return true if @available == true

        @available = begin
          connection.data_source_exists?(table_name)
        rescue ActiveRecord::ActiveRecordError, ActiveRecord::NoDatabaseError
          false
        end
      end

      # Reads a value. Returns `fallback` when the row or the table is missing.
      def get(scope, key, owner: nil, fallback: nil)
        return fallback unless available?

        row = find_by(scope: scope.to_s, owner_id: owner&.id, key: key.to_s)
        row ? row.value : fallback
      end

      # Writes a value, creating or updating the single row for that key.
      # A nil value deletes the row, which is how "no explicit choice" (follow
      # the OS) is represented — distinct from an explicit "light" or "dark".
      def set(scope, key, value, owner: nil)
        return unless available?

        row = find_or_initialize_by(scope: scope.to_s, owner_id: owner&.id, key: key.to_s)
        if value.nil?
          row.destroy if row.persisted?
        else
          row.update!(value: value.to_s)
        end
        value
      end

      # Everything in one scope as a Hash, e.g. the whole settings screen.
      # Named `values_in` rather than `all` because `all` is ActiveRecord's own
      # relation entry point and overriding it breaks every query on the model.
      def values_in(scope, owner: nil)
        return {} unless available?

        where(scope: scope.to_s, owner_id: owner&.id).pluck(:key, :value).to_h
      end

      # Test hook: memoised availability must not survive a schema change.
      def reset_cache!
        @available = nil
      end
    end
  end
end
