# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy" do
  before do
    authorize_user(:as_admin)
    allow_any_instance_of(ActionDispatch::Request)
      .to receive(:content_security_policy_nonce) { "test-nonce" }
  end

  # Script tags that carry no src attribute, and therefore need a nonce to run
  # under a policy that does not allow 'unsafe-inline'. JSON data blocks are
  # never executed, so the policy does not apply to them.
  def inline_scripts_without_nonce
    response.body.scan(/<script(?![^>]*\ssrc=)(?![^>]*\stype="application\/json")[^>]*>/)
      .reject { _1.include?('nonce="test-nonce"') }
  end

  it "nonces the inline scripts of the admin layout" do
    get laiss_cms.admin_dashboard_path
    expect(inline_scripts_without_nonce).to be_empty
  end

  it "nonces the inline scripts of the page edit view" do
    page = create(:laiss_cms_page)
    get laiss_cms.edit_admin_page_path(page)
    expect(inline_scripts_without_nonce).to be_empty
  end

  it "nonces the inline scripts of the pictures index view" do
    create(:laiss_cms_language)
    get laiss_cms.admin_pictures_path
    expect(inline_scripts_without_nonce).to be_empty
  end

  it "nonces the inline scripts of the nodes index view" do
    create(:laiss_cms_language)
    get laiss_cms.admin_nodes_path
    expect(inline_scripts_without_nonce).to be_empty
  end
end
