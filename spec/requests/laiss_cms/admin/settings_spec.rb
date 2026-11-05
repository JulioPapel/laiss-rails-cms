# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin settings", type: :request do
  let(:admin) { create(:laiss_cms_dummy_user, :as_admin) }

  before do
    LaissCms::Preference.reset_cache!
    LaissCms::Preference.where(scope: LaissCms::Preference::SETTINGS).delete_all
    authorize_user(admin)
  end

  # Config is global state and these examples write it through the real
  # controller. Restore the values that were actually there before the example
  # rather than the catalogue defaults: `auto_logout_time` defaults to 30 in the
  # catalogue but is 40 in the dummy app's config.yml, so writing the default
  # back silently corrupted the boot value for every later example.
  around do |example|
    fields = LaissCms::Admin::Settings.writable
    previous = fields.to_h { |field| [field.key, LaissCms::Admin::Settings.read(field)] }

    begin
      example.run
    ensure
      previous.each do |key, value|
        field = fields.find { |candidate| candidate.key == key }
        LaissCms::Admin::Settings.write(field, value, check_options: false) if field
      end
      LaissCms::Preference.where(scope: LaissCms::Preference::SETTINGS).delete_all
    end
  end

  describe "GET /admin/settings" do
    it "renders" do
      get laiss_cms.admin_settings_path
      expect(response).to have_http_status(:ok)
    end

    it "renders a section for each group" do
      get laiss_cms.admin_settings_path
      html = Nokogiri::HTML(response.body)

      expect(html.css(".settings-section").size).to eq(
        LaissCms::Admin::Settings::SECTIONS.size
      )
    end

    it "renders a control for every writable field" do
      get laiss_cms.admin_settings_path
      html = Nokogiri::HTML(response.body)

      LaissCms::Admin::Settings.writable.each do |field|
        expect(html.at_css("#settings_#{field.key.tr(".", "_")}")).to be_present,
          "missing control for #{field.key}"
      end
    end

    it "renders read-only values as output, not as inputs" do
      get laiss_cms.admin_settings_path
      html = Nokogiri::HTML(response.body)

      read_only = LaissCms::Admin::Settings::FIELDS.find(&:restart?)
      id = "settings_#{read_only.key.tr(".", "_")}"

      expect(html.at_css("output##{id}")).to be_present
      expect(html.at_css("input##{id}")).to be_nil
    end

    it "labels what applies at runtime and what needs a restart" do
      get laiss_cms.admin_settings_path
      html = Nokogiri::HTML(response.body)

      expect(html.css(".settings-badge--runtime")).to be_present
      expect(html.css(".settings-badge--restart")).to be_present
    end

    it "is linked from the main navigation" do
      get laiss_cms.admin_settings_path
      html = Nokogiri::HTML(response.body)

      link = html.at_css("#main_navi a[href='#{laiss_cms.admin_settings_path}']")
      expect(link).to be_present
    end
  end

  describe "PATCH /admin/settings" do
    it "saves a runtime value onto the config" do
      patch laiss_cms.admin_settings_path, params: {settings: {items_per_page: "25"}}

      expect(response).to redirect_to(laiss_cms.admin_settings_path)
      expect(LaissCms.config.items_per_page).to eq(25)
    end

    it "persists the value so it survives a restart" do
      patch laiss_cms.admin_settings_path, params: {settings: {items_per_page: "25"}}

      stored = LaissCms::Preference.get(LaissCms::Preference::SETTINGS, "config")
      expect(stored).to be_present
      expect(LaissCms::Admin::Settings.restore(stored)).to include("items_per_page" => 25)
    end

    it "restores a persisted value onto a fresh config, as boot does" do
      patch laiss_cms.admin_settings_path, params: {settings: {items_per_page: "25"}}
      stored = LaissCms::Preference.get(LaissCms::Preference::SETTINGS, "config")

      fresh = LaissCms::Configurations::Main.new
      LaissCms::Admin::Settings.apply_snapshot(
        fresh, LaissCms::Admin::Settings.restore(stored)
      )

      expect(fresh.items_per_page).to eq(25)
    end

    it "saves a nested value" do
      patch laiss_cms.admin_settings_path,
        params: {settings: {"uploader.file_size_limit": "42"}}

      expect(LaissCms.config.uploader.file_size_limit).to eq(42)
    end

    it "saves a boolean" do
      patch laiss_cms.admin_settings_path, params: {settings: {cache_pages: "0"}}
      expect(LaissCms.config.cache_pages).to be(false)
    end

    it "rejects an invalid value and re-renders the form" do
      patch laiss_cms.admin_settings_path, params: {settings: {items_per_page: "0"}}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(LaissCms.config.items_per_page).to eq(15)
    end

    it "does not persist anything when a value is invalid" do
      patch laiss_cms.admin_settings_path, params: {settings: {items_per_page: "0"}}

      expect(
        LaissCms::Preference.get(LaissCms::Preference::SETTINGS, "config")
      ).to be_nil
    end

    it "rejects an unknown value for a select field" do
      create(:laiss_cms_language, language_code: "en")
      patch laiss_cms.admin_settings_path,
        params: {settings: {"default_language.code": "zz"}}
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "ignores a key that is not writable" do
      before_value = LaissCms.config.storage_adapter
      patch laiss_cms.admin_settings_path, params: {settings: {storage_adapter: "dragonfly"}}

      expect(LaissCms.config.storage_adapter).to eq(before_value)
    end
  end

  describe "permissions" do
    it "is forbidden to an author" do
      authorize_user(create(:laiss_cms_dummy_user, :as_author))
      get laiss_cms.admin_settings_path

      expect(response).not_to have_http_status(:ok)
    end

    it "is forbidden to an editor" do
      authorize_user(create(:laiss_cms_dummy_user, :as_editor))
      get laiss_cms.admin_settings_path

      expect(response).not_to have_http_status(:ok)
    end

    it "is hidden from the navigation for an author" do
      authorize_user(create(:laiss_cms_dummy_user, :as_author))
      get laiss_cms.admin_dashboard_path
      html = Nokogiri::HTML(response.body)

      expect(html.at_css("#main_navi a[href='#{laiss_cms.admin_settings_path}']")).to be_nil
    end
  end
end
