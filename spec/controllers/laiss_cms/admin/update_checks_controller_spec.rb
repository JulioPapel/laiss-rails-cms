# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::UpdateChecksController do
  routes { LaissCms::Engine.routes }

  let(:user) { build_stubbed(:laiss_cms_dummy_user, :as_admin) }

  before { authorize_user(user) }

  describe "#show" do
    around do |example|
      Rails.cache.clear unless example.metadata[:with_caching]
      example.run
    end

    context "requesting update-check endpoint" do
      before do
        allow(LaissCms::UpdateChecker).to receive(:new).with(origin: "test.host") do
          double(LaissCms::UpdateChecker,
            update_available?: false,
            latest_version: Gem::Version.new("2.6.2"))
        end
      end

      context "if current LaissCms version equals the latest released version or it is newer" do
        before do
          allow(LaissCms).to receive(:gem_version) do
            Gem::Version.new("2.6.2")
          end
        end

        it "returns json with up to date" do
          get :show
          expect(response.code).to eq("200")
          parsed_body = JSON.parse(response.body)
          expect(parsed_body).to eq({
            "status" => true,
            "latest_version" => "2.6.2",
            "message" => "LaissCms is up to date"
          })
        end
      end

      context "if current LaissCms version is older than latest released version" do
        before do
          allow(LaissCms).to receive(:gem_version) do
            Gem::Version.new("2.5.0")
          end
          allow(LaissCms::UpdateChecker).to receive(:new).with(origin: "test.host") do
            double(LaissCms::UpdateChecker,
              update_available?: true,
              latest_version: Gem::Version.new("2.6.0"))
          end
        end

        it "returns json with update available" do
          get :show
          expect(response.code).to eq("200")
          parsed_body = JSON.parse(response.body)
          expect(parsed_body).to eq({
            "status" => false,
            "latest_version" => "2.6.0",
            "message" => "Update available"
          })
        end
      end
    end

    context "update-check endpoint is unavailable" do
      before do
        allow(LaissCms::UpdateChecker).to receive(:new).with(origin: "test.host") do
          raise LaissCms::UpdateServiceUnavailable
        end
      end

      it "returns json with update status unavailable" do
        get :show
        expect(response.code).to eq("503")
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to eq({
          "message" => "Update status unavailable"
        })
      end
    end

    context "caching" do
      around do |example|
        original_cache_store = Rails.cache
        Rails.cache = ActiveSupport::Cache::MemoryStore.new
        example.run
        Rails.cache = original_cache_store
      end

      before do
        Rails.cache.clear
        allow(LaissCms::UpdateChecker).to receive(:new).with(origin: "test.host") do
          double(LaissCms::UpdateChecker,
            update_available?: true,
            latest_version: Gem::Version.new("2.6.0"))
        end
        allow(LaissCms).to receive(:gem_version) do
          Gem::Version.new("2.5.0")
        end
      end

      it "caches the result for 1 hour", :with_caching do
        get :show
        get :show

        expect(LaissCms::UpdateChecker).to have_received(:new).once
      end

      it "fetches new data after cache expires", :with_caching do
        get :show
        expect(JSON.parse(response.body)["latest_version"]).to eq("2.6.0")

        travel 61.minutes do
          allow(LaissCms::UpdateChecker).to receive(:new).with(origin: "test.host") do
            double(LaissCms::UpdateChecker,
              update_available?: true,
              latest_version: Gem::Version.new("4.0.0"))
          end

          get :show
          expect(JSON.parse(response.body)["latest_version"]).to eq("4.0.0")
        end
      end
    end
  end
end
