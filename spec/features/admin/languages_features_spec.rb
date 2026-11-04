# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Languages Features", type: :system do
  before do
    authorize_user(:as_admin)
  end

  describe "creating a new language" do
    context "when selected locale is not an available locale" do
      before do
        create(:laiss_cms_site)
        allow(::I18n).to receive(:available_locales) { [:de, :en] }
      end

      it "shows a locale select and an error message" do
        visit laiss_cms.new_admin_language_path

        fill_in "language_language_code", with: "kl"
        click_button "Save"

        expect(page).to have_select("language_locale", options: %w[de en])
        expect(page).to have_selector(".language_locale.field_with_errors .error")
      end
    end

    context "with multiple sites" do
      let!(:default_site) { create(:laiss_cms_site, :default) }

      let!(:site_2) do
        create(:laiss_cms_site, host: "another-site.com")
      end

      let(:language) do
        LaissCms::Language.last
      end

      it "creates language for current site" do
        visit laiss_cms.new_admin_language_path

        fill_in "language_name", with: "Klingon"
        fill_in "language_language_code", with: "kl"
        fill_in "language_frontpage_name", with: "Tuq"
        click_button "Save"

        expect(language.site_id).to eq(LaissCms::Site.pluck(:id).first)
        expect(language.site_id).to_not eq(site_2.id)
      end
    end
  end

  describe "editing an language" do
    let!(:language) { create(:laiss_cms_language, :german) }

    context "when selected locale has multiple matching locale files" do
      before do
        allow(::I18n).to receive(:available_locales) { [:de, :"de-at", :en, :"en-uk"] }
      end

      it "shows a locale select with matching locales only" do
        visit laiss_cms.edit_admin_language_path(language)

        expect(page).to have_select("language_locale", options: ["de", "de-at"])
      end
    end

    context "when selected locale has one matching locale file" do
      before do
        allow(::I18n).to receive(:available_locales) { [:de, :en, :"en-uk"] }
      end

      it "shows a locale select with matching locale only" do
        visit laiss_cms.edit_admin_language_path(language)

        expect(page).to have_select("language_locale", options: %w[de])
      end
    end

    context "when selected locale has no matching locale files" do
      before do
        allow(::I18n).to receive(:available_locales) { [:jp, :es] }
      end

      it "shows a locale select with all available locales" do
        visit laiss_cms.edit_admin_language_path(language)

        expect(page).to have_select("language_locale", options: %w[jp es])
      end
    end
  end
end
