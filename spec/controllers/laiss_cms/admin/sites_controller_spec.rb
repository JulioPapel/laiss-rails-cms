# frozen_string_literal: true

require "rails_helper"

describe LaissCms::Admin::SitesController do
  routes { LaissCms::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#create" do
    context "with valid params" do
      it "redirects to the languages admin" do
        post :create, params: {site: {host: "*"}}
        site = LaissCms::Site.last
        expect(response).to redirect_to admin_languages_path(site_id: site)
        expect(flash[:info]).to eq("Please create a default language for this site.")
      end
    end

    context "with invalid params" do
      it "shows the form again" do
        post :create, params: {site: {host: ""}}
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#destroy" do
    let(:site) { create(:laiss_cms_site) }

    context "with languages attached" do
      let!(:language) { create(:laiss_cms_language, site: site) }

      it "returns with error message" do
        delete :destroy, params: {id: site.id}
        expect(response).to redirect_to admin_sites_path
        expect(flash[:warning]).to \
          eq("There are still languages attached to this site. Please remove them first.")
      end
    end

    context "without languages" do
      it "removes the site" do
        delete :destroy, params: {id: site.id}
        expect(response).to redirect_to admin_sites_path
        expect(flash[:notice]).to eq("Website successfully removed.")
      end
    end
  end
end
