# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Admin::Dashboard::Widgets::PageCounts, type: :component do
  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "without any pages" do
    it "renders zero count" do
      expect(rendered).to have_css(".widget-body")
      expect(rendered).to have_css(".count", text: "0")
    end

    it "renders zero published pages" do
      expect(rendered).to have_css(".infos", text: "0 #{LaissCms.t("published", scope: "admin.dashboard.widgets.page_counts")}")
    end
  end

  context "with pages" do
    before do
      create(:laiss_cms_page, :public)
      create(:laiss_cms_page)
    end

    it "renders the total count of pages" do
      expect(rendered).to have_css(".count", text: LaissCms::Page.count.to_s)
    end

    it "renders the count of published pages" do
      expect(rendered).to have_css(
        ".infos",
        text: "#{LaissCms::Page.published.count} #{LaissCms.t("published", scope: "admin.dashboard.widgets.page_counts")}"
      )
    end
  end

  it "renders the title" do
    expect(rendered).to have_text(LaissCms::Page.model_name.human(count: :many))
  end

  it "renders the icon" do
    expect(rendered).to have_css('laiss-cms-icon[name="pages"]')
  end

  it "renders a link to the pages admin" do
    expect(rendered).to have_link(href: LaissCms::Engine.routes.url_helpers.admin_pages_path)
  end
end
