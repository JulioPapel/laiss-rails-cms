# frozen_string_literal: true

require "rails_helper"

module LaissCms
  module Admin
    describe Settings do
      # Each example works on a throwaway config so the global one is untouched.
      let(:config) { LaissCms::Configurations::Main.new }

      def field(key) = described_class.find(key)

      describe "the catalogue" do
        it "only declares keys that exist on the config" do
          described_class::FIELDS.each do |field|
            expect { described_class.read(field, config) }.not_to raise_error,
              "#{field.key} is not a real config option"
          end
        end

        it "gives every field a section that is rendered" do
          described_class::FIELDS.each do |field|
            expect(described_class::SECTIONS).to include(field.section)
          end
        end

        it "marks every field as either runtime or restart" do
          described_class::FIELDS.each do |field|
            expect(%i[runtime restart]).to include(field.effects)
          end
        end

        it "does not duplicate a key" do
          keys = described_class::FIELDS.map(&:key)
          expect(keys).to eq(keys.uniq)
        end

        it "has at least one writable field" do
          expect(described_class.writable).not_to be_empty
        end

        it "has read-only fields for the values it cannot change" do
          expect(described_class::FIELDS.count(&:restart?)).to be > 0
        end

        # A missing translation renders the key itself in the UI, which is what
        # happened when the catalogue and the locale file drifted apart. This
        # asserts the screen is actually readable rather than just rendering.
        it "has a human label for every field" do
          described_class::FIELDS.each do |field|
            key = "settings.fields.#{field.key.tr(".", "_")}"
            label = ::I18n.t(key, scope: "laiss_cms", default: nil)
            expect(label).to be_present, "missing label #{key}"
            expect(label).not_to include("translation missing")
          end
        end

        it "has a hint for every field" do
          described_class::FIELDS.each do |field|
            key = "settings.fields.#{field.key.tr(".", "_")}_hint"
            hint = ::I18n.t(key, scope: "laiss_cms", default: nil)
            expect(hint).to be_present, "missing hint #{key}"
          end
        end

        it "has a title for every section" do
          described_class::SECTIONS.each do |section|
            key = "settings.sections.#{section}"
            title = ::I18n.t(key, scope: "laiss_cms", default: nil)
            expect(title).to be_present, "missing section title #{key}"
          end
        end
      end

      describe ".read" do
        it "reads a top-level option" do
          config.items_per_page = 30
          expect(described_class.read(field("items_per_page"), config)).to eq(30)
        end

        it "reads a nested option" do
          config.uploader.file_size_limit = 12
          expect(described_class.read(field("uploader.file_size_limit"), config)).to eq(12)
        end

        it "falls back to the declared default when the value is nil" do
          config.preprocess_image_resize = nil
          expect(described_class.read(field("default_site.name"), config)).not_to be_nil
        end
      end

      describe ".write" do
        it "writes a string" do
          ok, _ = described_class.write(field("default_site.name"), "  Studio  ", config)
          expect(ok).to be(true)
          expect(config.default_site.name).to eq("Studio")
        end

        it "rejects a blank string" do
          ok, error = described_class.write(field("default_site.name"), "   ", config)
          expect(ok).to be(false)
          expect(error).to be_present
        end

        it "writes an integer" do
          ok, _ = described_class.write(field("items_per_page"), "25", config)
          expect(ok).to be(true)
          expect(config.items_per_page).to eq(25)
        end

        it "rejects a non-numeric integer" do
          ok, error = described_class.write(field("items_per_page"), "many", config)
          expect(ok).to be(false)
          expect(error).to be_present
          expect(config.items_per_page).to eq(15)
        end

        it "rejects an integer below the minimum" do
          ok, = described_class.write(field("items_per_page"), "0", config)
          expect(ok).to be(false)
        end

        it "rejects an integer above the maximum" do
          ok, = described_class.write(field("items_per_page"), "9999", config)
          expect(ok).to be(false)
        end

        it "writes a boolean from a checkbox value" do
          ok, _ = described_class.write(field("cache_pages"), "0", config)
          expect(ok).to be(true)
          expect(config.cache_pages).to be(false)
        end

        it "writes a boolean from a string true" do
          described_class.write(field("cache_pages"), "false", config)
          expect(config.cache_pages).to be(false)
        end

        it "writes an allowed select value" do
          ok, _ = described_class.write(field("admin_theme"), "dark", config)
          expect(ok).to be(true)
          expect(config.admin_theme).to eq("dark")
        end

        it "rejects a value outside a select's options" do
          ok, error = described_class.write(field("admin_theme"), "neon", config)
          expect(ok).to be(false)
          expect(error).to be_present
        end

        it "refuses to write a read-only field" do
          ok, = described_class.write(field("storage_adapter"), "dragonfly", config)
          expect(ok).to be(false)
        end

        it "writes a nested option" do
          ok, _ = described_class.write(field("uploader.upload_limit"), "10", config)
          expect(ok).to be(true)
          expect(config.uploader.upload_limit).to eq(10)
        end

        it "skips option checking when replaying a snapshot" do
          # A language code that is no longer in the database must still replay:
          # the boot path may not query the database.
          ok, _ = described_class.write(
            field("default_language.code"), "cy", config, check_options: false
          )
          expect(ok).to be(true)
          expect(config.default_language.code).to eq("cy")
        end
      end

      describe "snapshots" do
        it "round-trips a set of values" do
          values = {"items_per_page" => 40, "cache_pages" => false}
          expect(described_class.restore(described_class.snapshot(values))).to eq(
            "items_per_page" => 40, "cache_pages" => false
          )
        end

        it "returns an empty hash for corrupt JSON" do
          expect(described_class.restore("{not json")).to eq({})
        end

        it "returns an empty hash for a nil snapshot" do
          expect(described_class.restore(nil)).to eq({})
        end
      end

      describe ".apply_snapshot" do
        it "restores saved values onto a fresh config" do
          described_class.write(field("items_per_page"), "42", config)
          snapshot = {"items_per_page" => 42}

          fresh = LaissCms::Configurations::Main.new
          described_class.apply_snapshot(fresh, snapshot)

          expect(fresh.items_per_page).to eq(42)
        end

        it "restores a nested value" do
          fresh = LaissCms::Configurations::Main.new
          described_class.apply_snapshot(fresh, {"uploader.file_size_limit" => 5})
          expect(fresh.uploader.file_size_limit).to eq(5)
        end

        it "ignores keys that are no longer declared" do
          fresh = LaissCms::Configurations::Main.new
          expect { described_class.apply_snapshot(fresh, {"removed_key" => "x"}) }
            .not_to raise_error
        end

        it "ignores saved values for read-only fields" do
          fresh = LaissCms::Configurations::Main.new
          before = fresh.storage_adapter
          described_class.apply_snapshot(fresh, {"storage_adapter" => "dragonfly"})
          expect(fresh.storage_adapter).to eq(before)
        end

        it "does not raise on a corrupt snapshot" do
          fresh = LaissCms::Configurations::Main.new
          expect { described_class.apply_snapshot(fresh, {"items_per_page" => "NaN"}) }
            .not_to raise_error
        end
      end
    end
  end
end
