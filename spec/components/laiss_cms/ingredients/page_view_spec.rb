# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::PageView, type: :component do
  let(:laiss_cms_page) { build(:laiss_cms_page, urlname: "a-page") }
  let(:ingredient) { LaissCms::Ingredients::Page.new(page: laiss_cms_page) }

  context "without page" do
    let(:ingredient) { LaissCms::Ingredients::Page.new }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with page" do
    it "renders a link to the page" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a[href='/#{laiss_cms_page.urlname}']")
    end

    it "has the page name as link text" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a:contains('#{laiss_cms_page.name}')")
    end
  end
end
