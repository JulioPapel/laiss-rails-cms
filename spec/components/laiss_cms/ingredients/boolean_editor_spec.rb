# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaissCms::Ingredients::BooleanEditor, type: :component do
  let(:element) { build_stubbed(:laiss_cms_element, name: "all_you_can_eat") }

  let(:ingredient) do
    LaissCms::Ingredients::Boolean.new(id: 123, role: "boolean", element: element)
  end

  before do
    vc_test_view_context.class.send :include, LaissCms::Admin::BaseHelper
  end

  subject do
    render_inline described_class.new(ingredient)
    page
  end

  it_behaves_like "an laiss_cms ingredient editor"

  it "renders a checkbox" do
    is_expected.to have_selector('input[type="checkbox"]')
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a disabled checkbox" do
      is_expected.to have_selector('input[type="checkbox"][disabled]')
    end
  end

  context "with default value given in ingredient settings" do
    let(:element) do
      create(:laiss_cms_element, :with_ingredients, name: "all_you_can_eat")
    end

    it "checks the checkbox" do
      within ".ingredient-editor boolean" do
        is_expected.to have_selector('input[type="checkbox"][checked="checked"]')
      end
    end
  end
end
