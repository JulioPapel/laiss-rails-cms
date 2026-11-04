# frozen_string_literal: true

RSpec.shared_examples_for "a controller that loads current language" do |args|
  context "when session has current language id key" do
    let!(:site_1) { create(:laiss_cms_site) }
    let!(:site_1_default_language) { create :laiss_cms_language, site: site_1, default: true }
    let!(:another_site_1_language) { create :laiss_cms_language, site: site_1, code: :de }
    let(:site_2) { create :laiss_cms_site, host: "another.host", languages: [build(:laiss_cms_language, code: :en), build(:laiss_cms_language, code: :de)] }

    context "on index action" do
      context "when switching the current site" do
        before do
          session[:laiss_cms_site_id] = site_1.id
          session[:laiss_cms_language_id] = another_site_1_language.id
        end

        it "sets @current_language to the new site default language" do
          get :index, params: {site_id: site_2.id}
          expect(assigns(:current_language)).to eq site_2.default_language
        end
      end

      context "when no language to set" do
        it "shows flash warning with redirect" do
          LaissCms::Language.destroy_all
          get :index, params: {site_id: site_1.id}
          expect(flash[:info]).to eq LaissCms.t("Please create a language first.")
          expect(response).to redirect_to admin_languages_path
        end
      end
    end
  end
end
