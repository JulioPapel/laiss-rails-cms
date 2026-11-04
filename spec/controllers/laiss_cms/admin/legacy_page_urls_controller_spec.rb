# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::LegacyPageUrlsController do
  routes { LaissCms::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#update" do
    subject do
      patch :update, params: {id: page_url.id, page_id: page.id, legacy_page_url: {urlname: ""}}
    end

    let(:page) { create(:laiss_cms_page) }
    let(:page_url) { LaissCms::LegacyPageUrl.create!(page: page, urlname: "foo") }

    context "with failing validations" do
      it "re-renders edit form" do
        expect(subject.status).to eq 422
        is_expected.to render_template(:edit)
      end
    end
  end
end
