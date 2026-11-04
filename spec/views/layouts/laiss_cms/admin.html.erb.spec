# frozen_string_literal: true

require "rails_helper"

RSpec.describe "layouts/laiss_cms/admin.html.erb" do
  before do
    view.extend LaissCms::Admin::BaseHelper
    allow(view).to receive(:laiss_cms_modules).and_return([])
    allow(view).to receive(:current_laiss_cms_user).and_return(DummyUser.new)
    allow(view).to receive(:configuration).and_return({})
  end

  subject do
    render template: "layouts/laiss_cms/admin"
    rendered
  end

  context "with LaissCms.config.admin_js_imports" do
    around do |example|
      current = LaissCms.config.admin_js_imports
      LaissCms.config.admin_js_imports << "foo"
      example.run
      LaissCms.config.admin_js_imports = current
    end

    it "renders the given javascripts module imports" do
      expect(subject).to have_selector("script[type=\"module\"]:last-of-type", text: /import "foo"/)
    end
  end

  context "without LaissCms.config.admin_js_imports" do
    it "does not render the given javascripts module imports" do
      expect(subject).to_not have_selector("script[type=\"module\"]:last-of-type", text: /import "foo"/)
    end
  end
end
