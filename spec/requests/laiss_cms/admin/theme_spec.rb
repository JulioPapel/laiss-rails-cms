# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin theme preference", type: :request do
  let(:user) { create(:laiss_cms_dummy_user, :as_admin) }

  before do
    LaissCms::Preference.reset_cache!
    LaissCms::Preference.where(scope: LaissCms::Preference::THEME).delete_all
    authorize_user(user)
  end

  def stored
    LaissCms::Preference.get(LaissCms::Preference::THEME, "mode", owner: user)
  end

  describe "PATCH /admin/theme" do
    it "persists an explicit dark choice" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      expect(stored).to eq("dark")
    end

    it "persists an explicit light choice" do
      patch laiss_cms.admin_theme_path, params: {theme: "light"}
      expect(stored).to eq("light")
    end

    it "clears the choice when following the system" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      patch laiss_cms.admin_theme_path, params: {theme: "system"}

      expect(stored).to be_nil
    end

    it "rejects an unknown theme" do
      patch laiss_cms.admin_theme_path, params: {theme: "neon"}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(stored).to be_nil
    end

    it "accepts a JSON body" do
      patch laiss_cms.admin_theme_path,
        params: {theme: "dark"}.to_json,
        headers: {"CONTENT_TYPE" => "application/json", "ACCEPT" => "application/json"}

      expect(stored).to eq("dark")
      expect(JSON.parse(response.body)).to eq("theme" => "dark")
    end

    it "keeps one user's choice away from another's" do
      other = create(:laiss_cms_dummy_user, :as_author)
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}

      expect(
        LaissCms::Preference.get(LaissCms::Preference::THEME, "mode", owner: other)
      ).to be_nil
    end
  end

  describe "rendering the choice" do
    def theme_attribute
      Nokogiri::HTML(response.body).at_css("html")["data-theme"]
    end

    it "renders no data-theme when the user follows the system" do
      get laiss_cms.admin_dashboard_path
      expect(theme_attribute).to be_nil
    end

    it "renders the saved dark choice on the next request" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to eq("dark")
    end

    it "renders the saved light choice on the next request" do
      patch laiss_cms.admin_theme_path, params: {theme: "light"}
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to eq("light")
    end

    it "survives a new session, because the choice is on the user not the browser" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      reset!

      get laiss_cms.admin_dashboard_path
      expect(theme_attribute).to eq("dark")
    end

    it "still honours the host's admin_theme config when the user has no choice" do
      allow(LaissCms.config).to receive(:admin_theme).and_return("light")
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to eq("light")
    end

    it "lets the user's choice win over the host's config" do
      allow(LaissCms.config).to receive(:admin_theme).and_return("light")
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to eq("dark")
    end
  end

  describe "the control itself" do
    it "is rendered in the top bar" do
      get laiss_cms.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).css("#user_info laiss-cms-theme-toggle")).to be_present
    end

    it "is rendered in the drawer" do
      get laiss_cms.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).css("#left_menu laiss-cms-theme-toggle")).to be_present
    end

    it "has an accessible name" do
      get laiss_cms.admin_dashboard_path
      toggle = Nokogiri::HTML(response.body).at_css("laiss-cms-theme-toggle")
      expect(toggle["label"]).to be_present
    end

    it "reports the saved choice to the control" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      get laiss_cms.admin_dashboard_path

      toggle = Nokogiri::HTML(response.body).at_css("#user_info laiss-cms-theme-toggle")
      expect(toggle["current"]).to eq("dark")
    end

    it "reports system when there is no saved choice" do
      get laiss_cms.admin_dashboard_path
      toggle = Nokogiri::HTML(response.body).at_css("#user_info laiss-cms-theme-toggle")
      expect(toggle["current"]).to eq("system")
    end
  end
end
