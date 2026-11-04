# frozen_string_literal: true

require "rails_helper"

module LaissCms
  describe Admin::DashboardController do
    routes { LaissCms::Engine.routes }

    let(:user) { build_stubbed(:laiss_cms_dummy_user, :as_admin) }

    before { authorize_user(user) }

    describe "#index" do
      it "renders the dashboard" do
        get :index
        expect(response).to render_template("laiss_cms/admin/dashboard/index")
      end
    end

    describe "#info" do
      it "is deprecated" do
        expect(LaissCms::Deprecation).to receive(:warn)
        get :info
      end
    end

    describe "#license" do
      it "reads the LICENSE file" do
        get :license
        expect(assigns(:license)).to include("Redistribution and use in source and binary forms")
      end
    end
  end
end
