# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale select", type: :system do
  let(:a_page) { create(:laiss_cms_page, :public) }

  before do
    allow(LaissCms::I18n).to receive(:translation_files).and_return ["laiss_cms.kl.yml", "laiss_cms.jp.yml", "laiss_cms.cz.yml"]
    authorize_user(:as_admin)
  end

  it "contains all locales in a selectbox" do
    visit admin_dashboard_path
    expect(page).to have_select("admin_locale", options: ["Kl", "Jp", "Cz"])
  end

  context "when having available_locales set for LaissCms::I18n" do
    before do
      allow(LaissCms::I18n).to receive(:available_locales).and_return [:jp, :cz]
    end

    it "provides only these locales" do
      visit admin_dashboard_path
      expect(page).to have_select("admin_locale", options: ["Jp", "Cz"])
    end
  end

  describe "user selects locale" do
    context "that is available" do
      before do
        allow(LaissCms::I18n).to receive(:available_locales).and_return [:kl]
      end

      it "switches the locale" do
        visit admin_dashboard_path(admin_locale: "kl")
        expect(page).to have_content("majQa' Dub")
      end
    end

    context "that is not available" do
      it "does not switch the locale" do
        visit admin_dashboard_path(admin_locale: "de")
        expect(page).to have_content("Welcome back")
      end
    end
  end
end
