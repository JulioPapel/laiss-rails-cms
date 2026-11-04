# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::Dashboard::Widgets::SystemInfo, type: :component do
  before do
    allow(vc_test_view_context).to receive(:render_icon).and_return("icon")
    allow(vc_test_view_context).to receive(:link_to_dialog).and_return("license link")
  end

  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  it "displays the LaissCms version" do
    rendered
    expect(page).to have_css(".version", text: LaissCms.version)
  end

  context "when git revision info is available" do
    before do
      allow(LaissCms).to receive(:git_revision_info).and_return(
        branch: "main",
        revision: "abc1234def5678"
      )
    end

    it "displays the branch and shortened revision" do
      rendered
      expect(page).to have_css(".version", text: "(main @ abc1234)")
    end
  end

  context "when only a revision is available" do
    before do
      allow(LaissCms).to receive(:git_revision_info).and_return(
        branch: nil,
        revision: "abc1234def5678"
      )
    end

    it "displays only the shortened revision" do
      rendered
      expect(page).to have_css(".version", text: "(abc1234)")
    end
  end

  context "when no git revision info is available" do
    before do
      allow(LaissCms).to receive(:git_revision_info).and_return(nil)
    end

    it "does not display a git source" do
      rendered
      expect(page).to have_css(".version", text: LaissCms.version)
      expect(page).to have_no_text("@")
    end
  end
end
