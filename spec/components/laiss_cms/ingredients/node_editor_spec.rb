# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::NodeEditor, type: :component do
  let(:element) { build_stubbed(:laiss_cms_element, name: "all_you_can_eat") }
  let(:ingredient_editor) { described_class.new(ingredient) }
  let(:ingredient) { LaissCms::Ingredients::Node.new(id: 123, element: element, role: "node") }

  before do
    vc_test_view_context.class.include LaissCms::Admin::BaseHelper
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  subject do
    render_inline ingredient_editor
    page
  end

  it_behaves_like "an laiss_cms ingredient editor"

  it "renders a node select" do
    is_expected.to have_css("input.laiss_cms_selectbox.full_width")
  end

  context "with a node related to ingredient" do
    let(:node) { LaissCms::Node.new(id: 1) }
    let(:ingredient) { LaissCms::Ingredients::Node.new(node: node, element: element, role: "role") }

    it "sets node id as value" do
      is_expected.to have_css('input.laiss_cms_selectbox[value="1"]')
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
