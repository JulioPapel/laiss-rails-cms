# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::PageEditor, type: :component do
  let(:element) { build_stubbed(:laiss_cms_element, name: "all_you_can_eat") }
  let(:ingredient_editor) { described_class.new(ingredient) }
  let(:ingredient) { LaissCms::Ingredients::Page.new(id: 1234, element: element, role: "page") }

  before do
    vc_test_view_context.class.include LaissCms::Admin::BaseHelper
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  subject do
    render_inline ingredient_editor
    page
  end

  it_behaves_like "an laiss_cms ingredient editor"

  it "renders a page input" do
    is_expected.to have_selector("laiss-cms-page-select input")
  end

  context "with a page related to ingredient" do
    let(:laiss_cms_page) { build_stubbed(:laiss_cms_page) }
    let(:ingredient) { LaissCms::Ingredients::Page.new(page: laiss_cms_page, element: element, role: "role") }

    it "sets page id as value" do
      is_expected.to have_selector("input[value=\"#{laiss_cms_page.id}\"]")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a disabled input field" do
      is_expected.to have_css("input[disabled]")
    end
  end
end
