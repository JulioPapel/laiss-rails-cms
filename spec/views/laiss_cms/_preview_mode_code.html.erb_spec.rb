# frozen_string_literal: true

require "rails_helper"

describe "laiss_cms/_preview_mode_code.html.erb" do
  let(:page) { create(:laiss_cms_page) }

  context "in preview mode" do
    before { LaissCms::Current.preview_page = page }

    it "includes the preview javascript" do
      render partial: "laiss_cms/preview_mode_code"
      expect(rendered).to have_selector("script[src*='laiss_cms/preview']", visible: :all)
    end

    it "does not render an inline script" do
      render partial: "laiss_cms/preview_mode_code"
      expect(rendered).to_not have_selector("script:not([src])", visible: :all)
    end
  end

  context "outside of preview mode" do
    it "renders nothing" do
      render partial: "laiss_cms/preview_mode_code"
      expect(rendered).to be_blank
    end
  end
end
