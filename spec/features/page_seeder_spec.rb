# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page seeding", type: :system do
  context "when db/seeds/laiss_cms/pages.yml file is present" do
    let(:seeds_file) do
      "spec/fixtures/pages.yml"
    end

    before do
      FileUtils.mkdir_p(Rails.root.join("db/seeds/laiss_cms"))
      FileUtils.cp(seeds_file, Rails.root.join("db/seeds/laiss_cms/pages.yml"))
      LaissCms::Seeder.instance_variable_set(:@_page_yml, nil)
    end

    subject(:seed) do
      LaissCms::Shell.silence!
      LaissCms::Seeder.seed!
    end

    context "when no pages are present yet" do
      before do
        LaissCms::Page.delete_all
      end

      it "seeds pages", :aggregate_failures do
        seed
        expect(LaissCms::Page.find_by(name: "Index")).to be_present
        expect(LaissCms::Page.find_by(name: "Home")).to be_present
        expect(LaissCms::Page.find_by(name: "About")).to be_present
        expect(LaissCms::Page.find_by(name: "Contact")).to be_present
        expect(LaissCms::Page.find_by(name: "Footer")).to be_present
      end

      it "public pages have two page versions" do
        seed
        home_page = LaissCms::Page.find_by(name: "Home")
        expect(home_page.public_version).to be_present
        expect(home_page.draft_version).to be_present
      end

      it "creates only one draft version per page" do
        seed
        LaissCms::Page.find_each do |page|
          expect(page.versions.draft.count).to eq(1)
        end
      end

      context "when more then one content root page is present" do
        let(:seeds_file) do
          "spec/fixtures/pages_with_two_roots.yml"
        end

        it "aborts" do
          expect {
            expect { seed }.to output.to_stderr
          }.to raise_error(SystemExit)
        end
      end
    end

    context "when pages are already present" do
      let!(:page) { create(:laiss_cms_page) }

      it "does not seed" do
        seed
        expect(LaissCms::Page.find_by(name: "Home")).to_not be_present
      end
    end

    after do
      FileUtils.rm_rf(Rails.root.join("db/seeds"))
    end
  end
end
