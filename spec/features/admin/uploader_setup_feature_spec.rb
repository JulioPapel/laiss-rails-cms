# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Uploader setup", type: :system do
  before do
    authorize_user(:as_admin)
  end

  it "renders uploader defaults as JSON" do
    visit admin_dashboard_path
    expect(page).to have_css(
      "script#laiss_cms_uploader_defaults",
      text: %("upload_limit":#{LaissCms.config.uploader.upload_limit}),
      visible: false
    )
  end
end
