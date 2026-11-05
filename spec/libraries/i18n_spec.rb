# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe ".t" do
    it "scopes translations intro laiss_cms namespace" do
      expect(::I18n).to receive(:t).with(:foo, default: "Foo", scope: ["laiss_cms"])
      ::LaissCms.t(:foo)
    end
  end

  describe ".l" do
    it "delegates to LaissCms::I18n.localize" do
      time = Time.current
      expect(LaissCms::I18n).to receive(:localize).with(time, format: "foo")
      LaissCms.l(time, format: "foo")
    end
  end

  describe I18n do
    # @@available_locales is class-level state on the engine's I18n module, and
    # examples in this file both read and write it. Without restoring it, the
    # value leaked into whichever file ran next, and the failures moved with the
    # random seed. Scoped to the whole `describe` rather than one context, because
    # `.available_locales=` sets it too and had no cleanup.
    around do |example|
      klass = LaissCms::I18n
      had = klass.class_variable_defined?(:@@available_locales)
      previous = had ? klass.class_variable_get(:@@available_locales) : nil

      begin
        example.run
      ensure
        if had
          klass.class_variable_set(:@@available_locales, previous)
        elsif klass.class_variable_defined?(:@@available_locales)
          klass.remove_class_variable(:@@available_locales)
        end
      end
    end

    describe ".available_locales" do
      subject { I18n.available_locales }
      it { is_expected.to be_a Array }
      it { is_expected.to include(:en) }

      context "when locales are already set in application available_locales" do
        it "returns them" do
          expect(Rails.application.config.i18n).to receive(:available_locales) { [:de, :it] }
          is_expected.to match_array([:de, :it])
        end
      end

      context "when locales are already set in @@available_locales" do
        before { I18n.class_variable_set(:@@available_locales, [:kl, :jp]) }
        it { is_expected.to match_array([:kl, :jp]) }
      end

      context "when locales are present in other gems" do
        before do
          expect(::I18n).to receive(:load_path) do
            ["/opt/gems/laiss_cms/config/locales/extra/laiss_cms.de.yml"]
          end
        end

        it "includes them" do
          is_expected.to eq([:de])
        end
      end

      context "when same locales are present in multiple gems" do
        before do
          expect(::I18n).to receive(:load_path) do
            [
              "/opt/gems/laiss-cms-devise/config/locales/laiss_cms.de.yml",
              "/opt/gems/laiss_cms/config/locales/extra/laiss_cms.de.yml"
            ]
          end
        end

        it "includes them only once" do
          is_expected.to eq([:de])
        end
      end

      context "when locales have long iso format" do
        before do
          expect(::I18n).to receive(:load_path) do
            ["/opt/gems/laiss_cms/config/locales/extra/laiss_cms.zh-CN.yml"]
          end
        end

        it "includes them in long format" do
          is_expected.to eq([:"zh-CN"])
        end
      end

      context "multiple locales" do
        before do
          expect(::I18n).to receive(:load_path) do
            [
              "/opt/gems/laiss_cms/config/locales/extra/laiss_cms.zh-CN.yml",
              "/opt/gems/laiss_cms/config/locales/extra/laiss_cms.de.yml"
            ]
          end
        end

        it "are sorted" do
          is_expected.to eq([:de, :"zh-CN"])
        end
      end
    end

    describe ".available_locales=" do
      it "assigns the given locales to @@available_locales" do
        I18n.available_locales = [:kl, :nl, :cn]
        expect(I18n.class_variable_get(:@@available_locales)).to eq([:kl, :nl, :cn])
      end
    end

    describe ".localize" do
      subject(:localize) { LaissCms::I18n.localize(date) }

      let(:date) { Date.new(2026, 9, 22) }

      context "with just a date given" do
        it "localizes by default laiss_cms date format" do
          is_expected.to eq("2026-09-22")
        end
      end

      context "with date and format given" do
        subject(:localize) { LaissCms::I18n.localize(date, format: ":foo") }

        it "localizes by given format" do
          is_expected.to eq(":foo")
        end
      end

      context "with time given" do
        let(:date) { Time.new(2026, 9, 22, 11, 43, 0, 0) }

        it "localizes with default laiss_cms time format" do
          is_expected.to eq("22-09-2026 11:43am")
        end
      end

      context "with nil given" do
        let(:date) { nil }

        it { is_expected.to be_nil }
      end
    end
  end
end
