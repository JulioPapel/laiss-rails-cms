require "rails_helper"

RSpec.describe LaissCms::UpdateChecker, type: :model do
  describe "#update_available?" do
    subject(:update_available?) { described_class.new(origin: "example.com").update_available? }

    context "with configured laiss_cms_app update-check endpoint" do
      before do
        stub_laiss_cms_config(update_check_service: :laiss_cms_app)
      end

      context "if current LaissCms version equals the latest released version or it is newer" do
        before do
          allow(LaissCms).to receive(:gem_version).and_return(Gem::Version.new("2.6.2"))
          expect_any_instance_of(LaissCms::UpdateChecks::LaissCmsApp).to receive(:latest_version) do
            Gem::Version.new("2.6.0")
          end
        end

        it "should be false" do
          expect(update_available?).to eq(false)
        end
      end

      context "if current LaissCms version is older than latest released version" do
        before do
          allow(LaissCms).to receive(:gem_version).and_return(Gem::Version.new("2.5.0"))
          expect_any_instance_of(LaissCms::UpdateChecks::LaissCmsApp).to receive(:latest_version) do
            Gem::Version.new("2.6.0")
          end
        end

        it "should be true" do
          expect(update_available?).to be(true)
        end
      end

      context "if update-check endpoint is unavailable" do
        before do
          expect_any_instance_of(LaissCms::UpdateChecks::LaissCmsApp).to receive(:latest_version) do
            raise LaissCms::UpdateServiceUnavailable
          end
        end

        it "should raise error" do
          expect { update_available? }.to raise_error(LaissCms::UpdateServiceUnavailable)
        end
      end
    end

    context "with configured ruby_gems update-check" do
      before do
        stub_laiss_cms_config(update_check_service: :ruby_gems)
      end

      context "if current LaissCms version equals the latest released version or it is newer" do
        before do
          allow(LaissCms).to receive(:gem_version).and_return(Gem::Version.new("2.6.2"))
          expect_any_instance_of(LaissCms::UpdateChecks::RubyGems).to receive(:latest_version) do
            Gem::Version.new("2.6.0")
          end
        end

        it "should be false" do
          expect(update_available?).to eq(false)
        end
      end

      context "if current LaissCms version is older than latest released version" do
        before do
          allow(LaissCms).to receive(:gem_version).and_return(Gem::Version.new("2.5.0"))
          expect_any_instance_of(LaissCms::UpdateChecks::RubyGems).to receive(:latest_version) do
            Gem::Version.new("2.6.0")
          end
        end

        it "should be true" do
          expect(update_available?).to be(true)
        end
      end

      context "if update-check endpoint is unavailable" do
        before do
          expect_any_instance_of(LaissCms::UpdateChecks::RubyGems).to receive(:latest_version) do
            raise LaissCms::UpdateServiceUnavailable
          end
        end

        it "should raise error" do
          expect { update_available? }.to raise_error(LaissCms::UpdateServiceUnavailable)
        end
      end
    end

    context "with configured none update-check" do
      before do
        stub_laiss_cms_config(update_check_service: :none)
      end

      before do
        allow(LaissCms).to receive(:gem_version).and_return(Gem::Version.new("2.6.2"))
      end

      it "should be false" do
        expect(update_available?).to eq(false)
      end
    end
  end
end
