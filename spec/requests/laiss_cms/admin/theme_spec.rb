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

  # The rendering side of the preference. It is intentionally inert now: the
  # layout no longer writes `data-theme`, because the product ships one theme.
  # These examples pin that down so a stale preference row or a host config
  # value cannot quietly reintroduce a second theme on screen.
  describe "rendering the choice" do
    def theme_attribute
      Nokogiri::HTML(response.body).at_css("html")["data-theme"]
    end

    it "renders no data-theme when the user follows the system" do
      get laiss_cms.admin_dashboard_path
      expect(theme_attribute).to be_nil
    end

    it "renders no data-theme even after a saved dark choice" do
      patch laiss_cms.admin_theme_path, params: {theme: "dark"}
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to be_nil
    end

    it "renders no data-theme even when the host pins admin_theme" do
      allow(LaissCms.config).to receive(:admin_theme).and_return("dark")
      get laiss_cms.admin_dashboard_path

      expect(theme_attribute).to be_nil
    end
  end

  # The product ships a single theme, so there is no control to switch. These
  # examples assert the absence, because silently rendering a toggle that cannot
  # change anything would be worse than not rendering one: it would tell the user
  # a preference exists when it does not.
  #
  # The preference model and the theme endpoint are still tested above — they
  # remain in the engine so dark mode can be restored by putting the toggle back.
  describe "the single-theme UI" do
    it "does not render a theme toggle in the top bar" do
      get laiss_cms.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).css("#user_info laiss-cms-theme-toggle")).to be_empty
    end

    it "does not render a theme toggle in the drawer" do
      get laiss_cms.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).css("#left_menu laiss-cms-theme-toggle")).to be_empty
    end

    it "renders no data-theme attribute by default" do
      get laiss_cms.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).at_css("html")["data-theme"]).to be_nil
    end

    it "does not let a stale saved dark preference change the rendering" do
      # A row left behind by an earlier build must not resurrect dark mode.
      LaissCms::Preference.set(
        LaissCms::Preference::THEME, "mode", "dark", owner: user
      )
      get laiss_cms.admin_dashboard_path

      expect(Nokogiri::HTML(response.body).at_css("html")["data-theme"]).to be_nil
    end
  end
end
