# frozen_string_literal: true

require "rails_helper"

describe "laiss_cms/admin/attachments/_replace_button.html.erb" do
  let(:object) { LaissCms::Attachment.new }
  let(:file_attribute) { :file }
  let(:redirect_url) { "/admin/attachments" }

  before do
    allow(view).to receive(:admin_attachments_path).and_return("/admin/attachments")
    view.extend LaissCms::BaseHelper
  end

  it "renders a laiss-cms-uploader component" do
    render partial: "laiss_cms/admin/attachments/replace_button",
      locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}
    expect(rendered).to have_selector("laiss-cms-uploader[redirect-url='/admin/attachments']")
  end

  context "with allowed_filetypes configured as wildcard" do
    before do
      allow(LaissCms.config.uploader.allowed_filetypes).to receive(:laiss_cms_attachments) do
        ["*"]
      end
    end

    it "does not render the accept attribute" do
      render partial: "laiss_cms/admin/attachments/replace_button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).not_to have_selector('input[type="file"][accept]')
    end
  end

  context "with allowed_filetypes configured as specific file types" do
    before do
      allow(LaissCms.config.uploader.allowed_filetypes).to receive(:laiss_cms_attachments) do
        ["pdf", "doc", "docx"]
      end
    end

    it "renders the accept attribute with the correct file extensions" do
      render partial: "laiss_cms/admin/attachments/replace_button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"][accept=".pdf, .doc, .docx"]')
    end
  end
end
