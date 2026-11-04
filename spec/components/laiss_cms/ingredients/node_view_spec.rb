# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::NodeView, type: :component do
  context "without node" do
    let(:ingredient) { LaissCms::Ingredients::Node.new }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with node" do
    let(:node) { build(:laiss_cms_node, url: "https://example.com") }
    let(:ingredient) { LaissCms::Ingredients::Node.new(node: node) }

    it "renders the node" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a[href='https://example.com']")
    end
  end
end
