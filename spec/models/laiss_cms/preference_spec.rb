# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe Preference do
    # The preference store only needs an object that responds to `id`; it does
    # not care what a user is. Using plain doubles keeps this spec in the core
    # suite, which does not load the devise test factories.
    let(:owner) { double("owner", id: 41) }
    let(:other_owner) { double("other owner", id: 42) }

    before { described_class.reset_cache! }

    describe ".get" do
      it "returns the fallback when nothing is stored" do
        expect(described_class.get(:theme, "mode", fallback: "system")).to eq("system")
      end

      it "returns the stored value" do
        described_class.set(:theme, "mode", "dark", owner: owner)
        expect(described_class.get(:theme, "mode", owner: owner)).to eq("dark")
      end

      it "scopes values to their owner" do
        described_class.set(:theme, "mode", "dark", owner: owner)
        expect(described_class.get(:theme, "mode", owner: other_owner)).to be_nil
      end

      it "scopes values to their scope" do
        described_class.set(:theme, "mode", "dark", owner: owner)
        expect(described_class.get(:settings, "mode", owner: owner)).to be_nil
      end

      it "treats an engine-wide row as distinct from a per-user row" do
        described_class.set(:settings, "config", "{}", owner: nil)
        expect(described_class.get(:settings, "config", owner: owner)).to be_nil
      end
    end

    describe ".set" do
      it "creates a row" do
        expect { described_class.set(:theme, "mode", "light", owner: owner) }
          .to change(described_class, :count).by(1)
      end

      it "updates the existing row rather than adding another" do
        described_class.set(:theme, "mode", "light", owner: owner)
        expect { described_class.set(:theme, "mode", "dark", owner: owner) }
          .not_to change(described_class, :count)
        expect(described_class.get(:theme, "mode", owner: owner)).to eq("dark")
      end

      it "deletes the row when the value is nil" do
        described_class.set(:theme, "mode", "dark", owner: owner)
        expect { described_class.set(:theme, "mode", nil, owner: owner) }
          .to change(described_class, :count).by(-1)
        expect(described_class.get(:theme, "mode", owner: owner)).to be_nil
      end

      it "is a no-op when clearing a row that does not exist" do
        expect { described_class.set(:theme, "mode", nil, owner: owner) }
          .not_to change(described_class, :count)
      end

      it "stores values as strings" do
        described_class.set(:settings, "items", 42)
        expect(described_class.get(:settings, "items")).to eq("42")
      end
    end

    describe ".values_in" do
      it "returns every value in a scope as a hash" do
        described_class.set(:settings, "a", "1")
        described_class.set(:settings, "b", "2")
        expect(described_class.values_in(:settings)).to eq({"a" => "1", "b" => "2"})
      end

      it "excludes other scopes" do
        described_class.set(:settings, "a", "1")
        described_class.set(:theme, "b", "2")
        expect(described_class.values_in(:settings).keys).to eq(["a"])
      end

      it "returns an empty hash when the scope has no rows" do
        expect(described_class.values_in(:settings)).to eq({})
      end
    end

    describe "when the table is missing" do
      before do
        allow(described_class).to receive(:available?).and_return(false)
      end

      it "reads the fallback instead of raising" do
        expect(described_class.get(:theme, "mode", fallback: "system")).to eq("system")
      end

      it "ignores writes instead of raising" do
        expect { described_class.set(:theme, "mode", "dark") }.not_to raise_error
      end

      it "returns an empty hash" do
        expect(described_class.values_in(:settings)).to eq({})
      end
    end

    describe ".available?" do
      it "is true when the migration has been run" do
        expect(described_class.available?).to be(true)
      end
    end
  end
end
